let NotificationsHooks = {};

NotificationsHooks.Notification = {
    mounted() {
        if (Notification.permission === "default") {
            this.pushEvent("Bonfire.Notifications:request")
            console.debug("notification permission needs to be requested ")
        } else {
            console.debug("notification permission was granted ")
        }

        this.handleEvent("notify", ({ title, message }) => sendNotification(title, message));
    }
}

function sendNotification(title, message) {
    if (Notification.permission === "granted") {
        try {
            new Notification(title, { body: message, requireInteraction: false });
        } catch (e) {
            console.debug("notification error: " + e)
        }
    } else {
        Notification.requestPermission();
    }
}

export { NotificationsHooks }