export interface ZoneInfo {
  name: string;
  label: string;
  weather: string;
  hour: number;
  minutes: number;
  temperature: number;
  type: string;
  time: string;
  wind: number;
  freeze: boolean;
}

export interface SelectType {
  value: string;
  label: string;
}
