import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

//Find all tokens for a specified user
const findTokensFromUser = async (userId: string) => {
    const tokens: string[] = [];
    await admin.firestore().collection('devices').where('userId', '==', userId)
        .get()
        .then((val) => {
            val.forEach(
                doc => tokens.push(doc.data().token)
            );
        });
    return tokens;
}

const findTokenFromUserList = async (subscribers: string[]) => {
    const tokens: string[] = [];
    for (const subscriber of subscribers) {
        tokens.push(...await findTokensFromUser(subscriber));
    }
    return tokens;
}

const sendMessage = async (subscribersTokens: string[], payload: any) => {
    if (subscribersTokens.length > 0) {
        await admin.messaging().sendToDevice(subscribersTokens, payload).then((response) => {
            // For each message check if there was an error.
            response.results.forEach(async (result, idx) => {
                const error = result.error;
                if (error) {
                    // Cleanup the tokens who are not registered anymore.
                    if (error.code === 'messaging/invalid-registration-token' ||
                        error.code === 'messaging/registration-token-not-registered') {
                        await admin.firestore().collection('devices').doc(subscribersTokens[idx]).delete();
                    }
                }
            });
        });
    }

}

export const onMessageCreated = functions.region('europe-west1').firestore
    .document('conversations/{convId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const message = snapshot.data()!;
        let senderName = '';
        await admin.firestore().collection('users').where('uid', '==', message.sender).limit(1)
            .get()
            .then((val) => {
                val.forEach(
                    doc => senderName = doc.data().displayName
                );
            });

        const title = 'New message from ' + senderName + ' !';
        let body = message.content;
        if (message.content.indexOf('vocal-message-header//') !== -1) {
            body = 'New voice message !';
        }

        const payload = {
            notification: {
                title,
                body
            }
        }
        await sendMessage(await findTokenFromUserList(message.receivers), payload);
    });


