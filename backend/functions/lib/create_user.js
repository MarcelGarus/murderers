"use strict";
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
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
const util_1 = require("util");
const utils_1 = require("./utils");
const constants_1 = require("./constants");
/// Creates a new user id.
function createUserId(firestore) {
    return __awaiter(this, void 0, void 0, function* () {
        let id = '';
        let tries = 0;
        while (true) {
            id = utils_1.generateRandomString(constants_1.USER_ID_CHARS, constants_1.USER_ID_LENGTH);
            tries++;
            const snapshot = yield utils_1.userRef(firestore, id).get();
            if (!snapshot.exists)
                break;
        }
        util_1.log('It took ' + tries + ' tries to create the user ' + id + '.');
        return id;
    });
}
/// Offers webhook for creating a new user.
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!utils_1.queryContains(req.query, [
            'authToken', 'messagingToken', 'name'
        ], res))
            return;
        const firestore = admin.app().firestore();
        const authToken = req.query.authToken;
        const messagingToken = req.query.messagingToken;
        const name = req.query.name;
        util_1.log('Creating a user named ' + name + '. Auth token: ' + authToken + ' Messaging token: ' + messagingToken);
        // TODO: Confirm Firebase Auth token.
        // If the user already exists, just return the existing user id.
        const existingUser = yield firestore
            .collection('users')
            .where('authToken', '==', authToken)
            .limit(1).get();
        if (existingUser.size > 0) {
            res.set('application/json').send({
                id: existingUser.docs[0].id,
            });
            return;
        }
        // Create the user.
        const user = {
            authToken: authToken,
            messagingToken: messagingToken,
            name: name,
        };
        const id = yield createUserId(firestore);
        yield utils_1.userRef(firestore, id).set(user);
        util_1.log('User created.');
        // Send back the code.
        res.set('application/json').send({
            id: id,
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=create_user.js.map