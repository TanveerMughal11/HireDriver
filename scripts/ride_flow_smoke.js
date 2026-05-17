require('dotenv').config({ path: './.env' });
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const fetch = require('node-fetch');

// Models (assuming paths based on common backend structures)
const User = require('./models/User'); 
const RideRequest = require('./models/RideRequest');

async function run() {
    const RESULT = {
        cleanup: {},
        declineFlow: {},
        acceptFlow: {},
        httpStatusTrail: []
    };

    try {
        await mongoose.connect(process.env.MONGO_URI);
        
        // 1. Cleanup
        const before = await RideRequest.countDocuments();
        await RideRequest.deleteMany({});
        const after = await RideRequest.countDocuments();
        RESULT.cleanup = { before, after };

        // 2. Create Users
        const timestamp = Date.now();
        const passenger = await User.create({
            fullName: 'Test Passenger',
            email: `passenger_\@example.com`,
            password: 'password123',
            role: 'user',
            isVerified: true
        });
        
        const rider = await User.create({
            fullName: 'Test Rider',
            email: `rider_\@example.com`,
            password: 'password123',
            role: 'rider',
            isVerified: true,
            isBlocked: false,
            driverAvailability: { status: 'online', isLive: true }
        });

        const passengerToken = jwt.sign({ id: passenger._id }, process.env.JWT_SECRET);
        const riderToken = jwt.sign({ id: rider._id }, process.env.JWT_SECRET);

        const apiBase = 'http://localhost:5000/api';

        async function apiCall(path, method, token, body = null) {
            const url = `\\`;
            const res = await fetch(url, {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer \`
                },
                body: body ? JSON.stringify(body) : null
            });
            const data = res.status !== 204 ? await res.json() : null;
            RESULT.httpStatusTrail.push({ path, method, status: res.status });
            if (res.status >= 400) throw new Error(`API Error \ on \: \`);
            return data;
        }

        // 3. Decline Flow
        const ride1 = await apiCall('/rides', 'POST', passengerToken, {
            pickupLocation: { address: 'Start 1', latitude: 0, longitude: 0 },
            destinationLocation: { address: 'End 1', latitude: 1, longitude: 1 },
            fare: 50,
            distance: '5km',
            duration: '10 mins'
        });
        
        await apiCall(`/rides/\/broadcast`, 'POST', passengerToken);
        
        const incoming = await apiCall('/rider-requests/incoming-requests', 'GET', riderToken);
        RESULT.declineFlow.incomingFound = incoming.data.length > 0;
        
        const targetReq = incoming.data.find(r => r.rideRequest._id === ride1.data._id);
        if (targetReq) {
            await apiCall(`/rider-requests/\/decline`, 'POST', riderToken);
            RESULT.declineFlow.declineSuccess = true;
        }

        const ride1Status = await apiCall(`/rides/\`, 'GET', passengerToken);
        RESULT.declineFlow.passengerDecision = ride1Status.data.passengerDecision;
        RESULT.declineFlow.offerStatuses = ride1Status.data.driverOffers.map(o => o.status);

        // 4. Accept Flow
        const ride2 = await apiCall('/rides', 'POST', passengerToken, {
            pickupLocation: { address: 'Start 2', latitude: 0, longitude: 0 },
            destinationLocation: { address: 'End 2', latitude: 1, longitude: 1 },
            fare: 60,
            distance: '6km',
            duration: '12 mins'
        });

        await apiCall(`/rides/\/broadcast`, 'POST', passengerToken);
        
        const incoming2 = await apiCall('/rider-requests/incoming-requests', 'GET', riderToken);
        const targetReq2 = incoming2.data.find(r => r.rideRequest._id === ride2.data._id);
        
        if (targetReq2) {
            await apiCall(`/rider-requests/\/accept`, 'POST', riderToken);
            RESULT.acceptFlow.acceptSuccess = true;
        }

        const ride2Status = await apiCall(`/rides/\`, 'GET', passengerToken);
        RESULT.acceptFlow.rideStatus = ride2Status.data.status;
        RESULT.acceptFlow.passengerAccepted = ride2Status.data.passengerUpdate?.accepted;
        RESULT.acceptFlow.passengerMessage = ride2Status.data.passengerUpdate?.message;

        console.log('RESULT=' + JSON.stringify(RESULT, null, 2));

    } catch (err) {
        console.error('FAILED:', err.message);
        process.exit(1);
    } finally {
        await mongoose.disconnect();
    }
}

run();
