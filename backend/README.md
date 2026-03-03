# E Vahan — Node.js Backend

Express + MongoDB + Firebase Admin + Cloudinary + Socket.io

## Setup

### 1. Copy env file
```bash
cp .env.example .env
```
Fill in all values:
- **MONGO_URI** → from [MongoDB Atlas](#mongodb-atlas)
- **FIREBASE_*\*** → from [Firebase Console](#firebase-admin)
- **CLOUDINARY_*\*** → from [Cloudinary Dashboard](#cloudinary)
- **JWT_SECRET** → any long random string

### 2. Install & run
```bash
npm install
npm run dev      # development (nodemon)
npm start        # production
```

Server starts at `http://localhost:5000`

---

## MongoDB Atlas (Free Tier)

1. Go to [cloud.mongodb.com](https://cloud.mongodb.com)
2. Create a free **M0** cluster
3. Create a DB user (username + password)
4. Whitelist IP: `0.0.0.0/0` (for development)
5. Click **Connect → Drivers** → copy the `mongodb+srv://...` URI
6. Paste into `MONGO_URI` in `.env`

---

## Firebase Admin SDK

1. Go to [Firebase Console](https://console.firebase.google.com) → your project
2. **Project Settings → Service accounts → Generate new private key**
3. Download the JSON file
4. Copy values into `.env`:
   - `FIREBASE_PROJECT_ID` = `project_id`
   - `FIREBASE_CLIENT_EMAIL` = `client_email`
   - `FIREBASE_PRIVATE_KEY` = `private_key` (keep the `\n` escapes)

---

## Cloudinary (Free Tier)

1. Sign up at [cloudinary.com](https://cloudinary.com/users/register/free)
2. Dashboard → **API Keys** → copy Cloud Name, API Key, API Secret
3. Paste into `.env`

---

## API Reference

| Method | URL | Auth | Description |
|--------|-----|------|-------------|
| POST | `/api/auth/login` | Firebase token | Login / register |
| GET | `/api/auth/me` | JWT | Get current user |
| PUT | `/api/auth/profile` | JWT | Update name |
| GET | `/api/listings` | — | Feed (filter + search) |
| POST | `/api/listings` | JWT | Post a new ad |
| GET | `/api/listings/my` | JWT | My Ads screen |
| GET | `/api/listings/:id` | — | Listing detail |
| PATCH | `/api/listings/:id/status` | JWT | Mark sold/delete |
| POST | `/api/chats` | JWT | Start a chat |
| GET | `/api/chats` | JWT | Buying/Selling tabs |
| GET | `/api/chats/:id/messages` | JWT | Message history |
| POST | `/api/chats/:id/messages` | JWT | Send message (HTTP) |

### Socket.io Events
| Event | Direction | Payload |
|-------|-----------|---------|
| `join_chat` | Client → Server | `chatId` |
| `send_message` | Client → Server | `{ chatId, text }` |
| `new_message` | Server → Client | `Message object` |

---

## Flutter Integration

After OTP success, Flutter:
1. Gets Firebase ID token: `await FirebaseAuth.instance.currentUser!.getIdToken()`
2. Calls `POST /api/auth/login` with `Authorization: Bearer <firebase_token>`
3. Receives `{ token, user }` — stores JWT in secure storage
4. Uses JWT for all subsequent API calls
