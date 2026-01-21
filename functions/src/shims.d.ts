declare module "firebase-functions/v2/https" {
  export const onRequest: any;
  export const onCall: any;
  export const HttpsError: any;
}

declare module "firebase-functions/params" {
  export const defineSecret: any;
  export const defineString: any;
}

declare module "firebase-admin/app" {
  export const initializeApp: any;
}

declare module "firebase-admin/auth" {
  export const getAuth: any;
}

declare module "firebase-admin/firestore" {
  export const FieldValue: any;
  export const getFirestore: any;
}

declare module "stripe" {
  const Stripe: any;
  export default Stripe;
}


