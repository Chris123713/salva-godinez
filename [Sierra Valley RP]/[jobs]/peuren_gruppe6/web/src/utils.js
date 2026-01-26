export const isEnvBrowser = () => !window.invokeNative;

export const noop = () => {};

export async function fetchNui(eventName, data, mockData) {
    const options = {
        method: 'post',
        headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data),
    };

    if (isEnvBrowser() && mockData) return mockData;

    const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'peuren_gruppe6';

    const resp = await fetch(`https://${resourceName}/${eventName}`, options);

    const respFormatted = await resp.json();

    return respFormatted;
}

export const registerEvent = (eventName, callback) => {
    if (isEnvBrowser()) return;

    window.addEventListener('message', (event) => {
        let data = event.data;
        if (data.action === eventName) {
            data = data.data;
        }
        if (data.type === eventName) {
            callback(data.data);
        }
    });
};