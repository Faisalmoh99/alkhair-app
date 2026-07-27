/** Jest config for Cloud Functions + Firestore rules unit tests (ts-jest). */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/test/**/*.spec.ts'],
  testTimeout: 30000,
};
