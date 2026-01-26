import { gtaToPixel, PixelPosition, getCalibrationStats } from './coordinateConverter';
import { calibrationPoints, CalibrationPoint } from '../data/calibration';

export interface Location {
  name: string;
  street: string;
  gtaX: number;
  gtaY: number;
}


export function convertLocationToPixel(
  location: Location,
  mapDimensions: { width: number; height: number }
): PixelPosition {
  return gtaToPixel(
    location.gtaX,
    location.gtaY,
    calibrationPoints,
    mapDimensions
  );
}


export function convertLocationsToPixels(
  locations: Location[],
  mapDimensions: { width: number; height: number }
): Array<Location & { pixelPosition: PixelPosition }> {
  return locations.map(location => ({
    ...location,
    pixelPosition: convertLocationToPixel(location, mapDimensions)
  }));
}


export function getAccuracyEstimate(gtaX: number, gtaY: number): {
  nearestDistance: number;
  nearestPoint: CalibrationPoint;
  reliability: 'high' | 'medium' | 'low';
} {
  let minDistance = Infinity;
  let nearestPoint = calibrationPoints[0];
  
  for (const point of calibrationPoints) {
    const distance = Math.sqrt(
      Math.pow(gtaX - point.gtaX, 2) + Math.pow(gtaY - point.gtaY, 2)
    );
    
    if (distance < minDistance) {
      minDistance = distance;
      nearestPoint = point;
    }
  }
  
  let reliability: 'high' | 'medium' | 'low';
  if (minDistance < 500) {
    reliability = 'high';
  } else if (minDistance < 1500) {
    reliability = 'medium';
  } else {
    reliability = 'low';
  }
  
  return {
    nearestDistance: minDistance,
    nearestPoint,
    reliability
  };
}


export function isLocationInCalibratedArea(location: Location): boolean {
  const stats = getCalibrationStats(calibrationPoints);
  if (!stats) return false;
  
  const { gtaBounds } = stats;
  return (
    location.gtaX >= gtaBounds.minX &&
    location.gtaX <= gtaBounds.maxX &&
    location.gtaY >= gtaBounds.minY &&
    location.gtaY <= gtaBounds.maxY
  );
}


export function getSuggestedCalibrationAreas(): Array<{ gtaX: number; gtaY: number; reason: string }> {
  const stats = getCalibrationStats(calibrationPoints);
  if (!stats) return [];
  
  const { gtaBounds } = stats;
  const suggestions = [];
  
  const corners = [
    { gtaX: gtaBounds.minX, gtaY: gtaBounds.minY, reason: 'Bottom-left corner' },
    { gtaX: gtaBounds.maxX, gtaY: gtaBounds.minY, reason: 'Bottom-right corner' },
    { gtaX: gtaBounds.minX, gtaY: gtaBounds.maxY, reason: 'Top-left corner' },
    { gtaX: gtaBounds.maxX, gtaY: gtaBounds.maxY, reason: 'Top-right corner' },
  ];
  
  for (const corner of corners) {
    const accuracy = getAccuracyEstimate(corner.gtaX, corner.gtaY);
    if (accuracy.nearestDistance > 300) {
      suggestions.push(corner);
    }
  }
  
  const centerX = (gtaBounds.minX + gtaBounds.maxX) / 2;
  const centerY = (gtaBounds.minY + gtaBounds.maxY) / 2;
  const centerAccuracy = getAccuracyEstimate(centerX, centerY);
  
  if (centerAccuracy.nearestDistance > 400) {
    suggestions.push({
      gtaX: centerX,
      gtaY: centerY,
      reason: 'Center point for better overall accuracy'
    });
  }
  
  return suggestions;
}


export function exportLocations(locations: Location[]): string {
  return JSON.stringify(locations, null, 2);
}


export function importLocations(jsonString: string): Location[] {
  try {
    const locations = JSON.parse(jsonString);
    if (Array.isArray(locations)) {
      return locations.filter(loc => 
        typeof loc.name === 'string' &&
        typeof loc.street === 'string' &&
        typeof loc.gtaX === 'number' &&
        typeof loc.gtaY === 'number'
      );
    }
    return [];
  } catch (error) {
    console.error('Failed to import locations:', error);
    return [];
  }
} 