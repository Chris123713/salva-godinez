export const isEnvBrowser = () => !window.invokeNative;

export const isInIframe = () => window.self !== window.top;

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

    // If in iframe (like laptop), don't send NUI requests
    if (isInIframe()) {
        console.log(`[${eventName}] Skipped - running in iframe`);
        return mockData || {};
    }

    const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'nui-frame-app';

    const resp = await fetch(`https://${resourceName}/${eventName}`, options);

    const respFormatted = await resp.json();

    return respFormatted;
}