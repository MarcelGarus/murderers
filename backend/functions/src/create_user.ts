/// Creates a new user.
///
/// Needs:
/// * user [name]
/// * Firebase [authToken]
/// * Firebase cloud [messagingToken]
///
/// Returns either:
/// 200: { id: 'abcdef...' }.
/// 400: Bad request.
/// 403: Access denied.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { log } from 'util';
import { FirebaseAuthToken, MessagingToken, UserId, User } from './models';
import { generateRandomString, queryContains, userRef } from './utils';
import { USER_ID_CHARS, USER_ID_LENGTH } from './constants';

/// Creates a new user id.
async function createUserId(
  firestore: FirebaseFirestore.Firestore
): Promise<UserId> {
  let id: UserId = '';
  let tries = 0;

  while (true) {
    id = generateRandomString(USER_ID_CHARS, USER_ID_LENGTH);
    tries++;

    const snapshot = await userRef(firestore, id).get();
    if (!snapshot.exists) break;
  }

  log('It took ' + tries + ' tries to create the user ' + id + '.');
  return id;
}

/// Offers webhook for creating a new user.
export async function handleRequest(
  req: functions.Request,
  res: functions.Response
): Promise<void> {
  if (!queryContains(req.query, [
    'authToken', 'messagingToken', 'name'
  ], res)) return;

  const firestore = admin.app().firestore();
  const authToken: FirebaseAuthToken = req.query.authToken;
  const messagingToken: MessagingToken = req.query.messagingToken;
  const name: string = req.query.name;

  log('Creating a user named ' + name + '. Auth token: ' + authToken + ' Messaging token: ' + messagingToken);

  // TODO: Confirm Firebase Auth token.

  // If the user already exists, just return the existing user id.
  const existingUser: FirebaseFirestore.QuerySnapshot = await firestore
    .collection('users')
    .where('authToken', '==', authToken)
    .limit(1).get();

  let id: UserId;
  if (existingUser.size > 0) {
    id = existingUser.docs[0].id;
  } else {
    id = await createUserId(firestore);
  }

  // Create the user.
  const user: User = {
    authToken: authToken,
    messagingToken: messagingToken,
    name: name,
  };

  await userRef(firestore, id).set(user);

  log('User created.');

  // Send back the code.
  res.set('application/json').send({
    id: id,
  });
}
