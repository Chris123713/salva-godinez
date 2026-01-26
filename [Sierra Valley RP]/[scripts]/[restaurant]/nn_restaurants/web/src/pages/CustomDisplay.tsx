import React, { useState, useEffect } from 'react'
import { useVisibility } from '../providers/VisibilityProvider'
import { useNuiEvent } from '../hooks/useNuiEvent';
import { t } from '../utils/translations';

type CustomContent = {
    type: 'youtube' | 'image' | 'gif';
    url: string;
}

const CustomDisplay = () => {
    const {visibility} = useVisibility();
    const [customContent, setCustomContent] = useState<CustomContent | null>(null);

    useNuiEvent<{customContent: CustomContent}>('setCustomContent', (data) => {
        setCustomContent(data.customContent);
    });

    if (!visibility.visible || visibility.page !== 'custom') return null;

    const renderContent = () => {
        if (!customContent) {
            return (
                <div className="flex items-center justify-center h-full w-full bg-black">
                    <p className="text-white text-4xl">{t('no_content_loaded')}</p>
                </div>
            );
        }

        switch (customContent.type) {
            case 'youtube':
                // Add autoplay=1 parameter to URL if not already present
                const embedUrl = customContent.url.includes('?') 
                    ? `${customContent.url}&autoplay=1` 
                    : `${customContent.url}?autoplay=1`;
                
                return (
                    <iframe
                        src={embedUrl}
                        className="w-full h-full"
                        frameBorder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowFullScreen
                    />
                );

            case 'image':
            case 'gif':
                return (
                    <div className="flex items-center justify-center h-full w-full bg-black">
                        <img
                            src={customContent.url}
                            alt={t('custom_display')}
                            className="max-w-full max-h-full object-contain"
                            onError={(e) => {
                                e.currentTarget.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzMzMzMzMyIvPjx0ZXh0IHg9IjUwIiB5PSI1MCIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjEyIiBmaWxsPSIjZmZmZmZmIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBkeT0iLjNlbSI+SW1hZ2UgTm90IEZvdW5kPC90ZXh0Pjwvc3ZnPg==';
                            }}
                        />
                    </div>
                );

            default:
                return (
                    <div className="flex items-center justify-center h-full w-full bg-black">
                        <p className="text-white text-4xl">{t('unsupported_content_type')}</p>
                    </div>
                );
        }
    };

    return (
        <div className="h-full w-full absolute top-0 left-0 z-99">
            {renderContent()}
        </div>
    );
};

export default CustomDisplay; 