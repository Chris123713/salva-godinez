
import { fetchNui } from './fetchNui';

export interface Translations {
  [key: string]: string;
}

let cachedTranslations: Translations = {};
let currentLanguage = 'en';
let translationCallbacks: ((translations: Translations) => void)[] = [];


export const onTranslationsReceived = (callback: (translations: Translations) => void): void => {
  translationCallbacks.push(callback);
};

export const handleTranslationsReceived = (translations: Translations): void => {
  cachedTranslations = translations;
  translationCallbacks.forEach(callback => callback(translations));
};

export const initializeTranslations = (): void => {
  fetchNui('requestTranslations', { language: currentLanguage });
};

export const t = (key: string, params?: Record<string, string | number>): string => {
  let translation = cachedTranslations[key] || key;

  if (params) {
    Object.keys(params).forEach(paramKey => {
      translation = translation.replace(`{${paramKey}}`, String(params[paramKey]));
    });
  }

  return translation;
};

export { cachedTranslations as translations }; 