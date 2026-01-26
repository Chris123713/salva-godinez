let localeData = {}

function getNestedValue(obj, path) {
    return path.split('.').reduce((current, key) => {
        return current?.[key];
    }, obj);
}

function locale(page, path, replacements = {}) {
    let text = getNestedValue(localeData[page], path) || path;
    
    for (const [key, value] of Object.entries(replacements)) {
        text = text.replace(new RegExp(`\\{\\{?${key}\\}?\\}`, 'g'), value);
    }
    
    return text;
}

function setLocale(data) {
    localeData = data;
}

export { locale, setLocale };