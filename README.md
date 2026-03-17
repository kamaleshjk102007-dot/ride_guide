# Amusement Park Management App

Mobile-first amusement park management system with:

- Flutter mobile app for visitors and admins
- Node.js + Express.js backend
- MongoDB database
- QR-based ride tickets
- Real-time-ready queue monitoring
- Ride popularity analytics
- Bright, animated amusement-park UI

## Project Structure

```text
backend/
  config/
  controllers/
  models/
  routes/
  utils/
  server.js

mobile_app/
  lib/
    models/
    screens/
    services/
    theme/
    widgets/
```

## Backend Setup

1. Go to the backend folder:

```bash
cd backend
```

2. Install dependencies:

```bash
npm install
```

3. Create a `.env` file from `.env.example`:

```env
PORT=5000
MONGODB_URI=mongodb://127.0.0.1:27017/amusement_park_mobile
JWT_SECRET=super-secret-key
ADMIN_EMAIL=admin@wonderpark.com
ADMIN_PASSWORD=Admin@123
```

4. Seed sample data:

```bash
npm run seed
```

5. Start the backend:

```bash
npm run dev
```

## Deploy Backend Online

The easiest path is MongoDB Atlas + Render.

1. Create a free MongoDB Atlas cluster and copy the connection string.
2. Put your project in a GitHub repository.
3. In Render, create a new `Web Service` from that repo.
4. Render can use [backend/render.yaml](x:\New folder\backend\render.yaml), or you can enter these manually:
   - Root Directory: `backend`
   - Build Command: `npm install`
   - Start Command: `npm start`
5. Add these environment variables in Render:
   - `MONGODB_URI`
   - `JWT_SECRET`
   - `ADMIN_EMAIL`
   - `ADMIN_PASSWORD`
6. After deploy, open:

```text
https://your-service-name.onrender.com/health
```

If that works, rebuild the Flutter APK using the hosted URL:

```bash
cd mobile_app
flutter build apk --release --dart-define=API_BASE_URL=https://your-service-name.onrender.com
```

This makes the APK use the online backend instead of your laptop IP.

## Flutter Setup

1. Go to the mobile app folder:

```bash
cd mobile_app
```

2. Install packages:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

For Android emulator, the default backend URL in the app uses `http://10.0.2.2:5000`.

## Main API Routes

- `POST /register`
- `POST /login`
- `GET /rides`
- `POST /rides`
- `PUT /rides/:id`
- `DELETE /rides/:id`
- `POST /tickets`
- `GET /tickets/:visitor_id`
- `POST /payments`
- `GET /payments`
- `POST /feedback`
- `GET /feedback`
- `GET /queue`
- `PUT /queue`
- `GET /analytics/dashboard`
- `GET /analytics/ride-popularity`
- `GET /analytics/visitor-stats`

## Sample Login

Visitor:

- `rahul@gmail.com`
- `visitor123`

Admin:

- `admin@wonderpark.com`
- `Admin@123`

## UI/UX Notes

- Soft gradients and glass cards for a playful premium look
- Animated splash and card transitions
- Card-first ride discovery flow
- Bottom navigation for quick mobile access
- Interactive-style park map
- Admin analytics cards and charts

## Notes

- The visitor schema includes a `password` field to support login.
- The ride schema includes `description` and `image` fields to support the richer mobile UI.
- Queue streaming endpoint is available at `GET /queue/stream` for future live updates in Flutter.
