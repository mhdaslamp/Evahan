const admin = require('firebase-admin');

if (!admin.apps.length) {
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    // dotenv reads \n as literal backslash-n — replace with real newline
    const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

    if (!projectId || !clientEmail || !privateKey) {
        throw new Error(
            `Firebase Admin: missing env vars.\n` +
            `  FIREBASE_PROJECT_ID   : ${projectId ? '✅' : '❌ MISSING'}\n` +
            `  FIREBASE_CLIENT_EMAIL : ${clientEmail ? '✅' : '❌ MISSING'}\n` +
            `  FIREBASE_PRIVATE_KEY  : ${privateKey ? '✅' : '❌ MISSING'}`
        );
    }

    admin.initializeApp({
        credential: admin.credential.cert({ projectId, clientEmail, privateKey }),
    });

    console.log('🔑 Firebase Admin initialised for project:', projectId);
}

module.exports = admin;
