declare const __DEV__: boolean;

// AgriVision Mobile App - API Service Integration
// Place this in your mobile app: src/services/AgriVisionAPI.ts

export interface WeatherForecast {
  daily: {
    temperature_2m_max: number[];
    temperature_2m_min: number[];
    precipitation_sum: number[];
    rain_sum: number[];
    windspeed_10m_max: number[];
  };
  farming_insights: {
    irrigation_recommendation: string;
    planting_window: string;
    disease_risk: string;
    harvest_timing: string;
  };
  alerts: Array<{
    type: string;
    severity: string;
    message: string;
  }>;
}

export interface CropDiagnosis {
  disease: string;
  confidence: number;
  severity: string;
  treatment: {
    immediate: string;
    preventive: string;
    organic_options: string[];
  };
  expected_yield_impact: string;
  monitoring_schedule: string;
}

export interface MarketPrice {
  commodity: string;
  region: string;
  current_price: number;
  currency: string;
  trend: 'increasing' | 'decreasing' | 'stable';
  historical: Array<{
    date: string;
    price: number;
  }>;
  recommendations: string[];
  last_updated: string;
}

export interface FarmerProfile {
  id: string;
  name: string;
  phone: string;
  location: {
    lat: number;
    lon: number;
    region: string;
  };
  farm_size_hectares: number;
  primary_crops: string[];
  experience_years: number;
  analytics: {
    total_seasons: number;
    avg_yield_per_hectare: number;
    revenue_last_year: number;
    profit_margin: number;
    sustainability_score: number;
  };
  recommendations: string[];
}

class AgriVisionAPI {
  private baseURL: string;
  private authToken: string | null = null;

  constructor(baseURL: string = __DEV__ ? 'http://localhost:4000' : 'https://your-production-url.com') {
    this.baseURL = baseURL;
  }

  setAuthToken(token: string) {
    this.authToken = token;
  }

  private async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...(this.authToken && { Authorization: `Bearer ${this.authToken}` }),
      ...options.headers,
    };

    try {
      const response = await fetch(url, { ...options, headers });
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.error || `HTTP ${response.status}: ${response.statusText}`);
      }
      
      return response.json();
    } catch (error) {
      if (error instanceof TypeError && error.message.includes('Network request failed')) {
        throw new Error('Network connection failed. Please check your internet connection.');
      }
      throw error;
    }
  }

  // Weather Services
  async getWeatherForecast(lat: number, lon: number, days: number = 7): Promise<WeatherForecast> {
    return this.request(`/weather/forecast?lat=${lat}&lon=${lon}&days=${days}`);
  }

  async getWeatherAlerts(lat: number, lon: number, cropType?: string) {
    const params = new URLSearchParams({ 
      lat: lat.toString(), 
      lon: lon.toString() 
    });
    if (cropType) params.append('crop_type', cropType);
    return this.request(`/weather/alerts?${params}`);
  }

  // Market Services
  async getMarketPrices(commodity: string, region: string, period: string = '30d'): Promise<MarketPrice> {
    const params = new URLSearchParams({ commodity, region, period });
    return this.request(`/market/prices?${params}`);
  }

  async getMarketOpportunities(lat: number, lon: number, radius: number = 50) {
    const params = new URLSearchParams({
      lat: lat.toString(),
      lon: lon.toString(),
      radius: radius.toString()
    });
    return this.request(`/market/opportunities?${params}`);
  }

  // AI Services
  async diagnoseCrop(imageBase64: string, cropType: string, symptoms?: string[]): Promise<CropDiagnosis> {
    return this.request('/ai/crop-diagnosis', {
      method: 'POST',
      body: JSON.stringify({
        image_base64: imageBase64,
        crop_type: cropType,
        symptoms: symptoms
      }),
    });
  }

  async analyzeSoil(imageBase64: string, location?: { lat: number; lon: number }) {
    return this.request('/ai/soil-analysis', {
      method: 'POST',
      body: JSON.stringify({
        image_base64: imageBase64,
        location: location
      }),
    });
  }

  async predictYield(cropType: string, plantingDate: string, areaHectares: number, historicalData?: any[]) {
    return this.request('/ai/yield-prediction', {
      method: 'POST',
      body: JSON.stringify({
        crop_type: cropType,
        planting_date: plantingDate,
        area_hectares: areaHectares,
        historical_data: historicalData
      }),
    });
  }

  // Communication Services
  async sendSMS(to: string, template: string, data?: any, customMessage?: string) {
    return this.request('/sms/send', {
      method: 'POST',
      body: JSON.stringify({
        to,
        template,
        data,
        custom_message: customMessage
      }),
    });
  }

  // Payment Services (M-Pesa)
  async initiateMpesaPayment(phone: string, amount: number, accountReference: string, description: string) {
    return this.request('/mpesa/stk-push', {
      method: 'POST',
      body: JSON.stringify({
        phone,
        amount,
        account_reference: accountReference,
        transaction_desc: description
      }),
    });
  }

  async getMpesaTransactions(userId: string, limit: number = 10) {
    const params = new URLSearchParams({
      user_id: userId,
      limit: limit.toString()
    });
    return this.request(`/mpesa/transactions?${params}`);
  }

  // Farmer Profile Services
  async getFarmerProfile(id: string): Promise<FarmerProfile> {
    return this.request(`/farmer/profile/${id}`);
  }

  async updateFarmerProfile(id: string, updates: Partial<FarmerProfile>) {
    return this.request(`/farmer/profile/${id}`, {
      method: 'PUT',
      body: JSON.stringify(updates),
    });
  }

  // Community Services
  async getCommunityPosts(region?: string, topic?: string, limit: number = 20) {
    const params = new URLSearchParams({ limit: limit.toString() });
    if (region) params.append('region', region);
    if (topic) params.append('topic', topic);
    return this.request(`/community/posts?${params}`);
  }

  async createCommunityPost(title: string, content: string, topic: string, region: string) {
    return this.request('/community/posts', {
      method: 'POST',
      body: JSON.stringify({
        title,
        content,
        topic,
        region
      }),
    });
  }

  // Authentication
  async verifyFirebaseToken(idToken: string) {
    return this.request('/auth/verify', {
      method: 'POST',
      body: JSON.stringify({ idToken }),
    });
  }

  // Push Notifications
  async sendPushNotification(token: string, title: string, body: string) {
    return this.request('/push/send', {
      method: 'POST',
      body: JSON.stringify({
        token,
        title,
        body
      }),
    });
  }

  // Health Check
  async getHealthStatus() {
    return this.request('/health');
  }

  // Offline Support Methods
  async syncOfflineData(offlineData: any[]) {
    return this.request('/sync/offline', {
      method: 'POST',
      body: JSON.stringify({ data: offlineData }),
    });
  }

  // Utility Methods
  async geocodeLocation(address: string) {
    const params = new URLSearchParams({ q: address });
    return this.request(`/geocode?${params}`);
  }
}

// Singleton instance
export const agriVisionAPI = new AgriVisionAPI();

// React Native Hook for AgriVision API
import { useState, useEffect } from 'react';

export function useAgriVisionAPI() {
  const [isOnline, setIsOnline] = useState(true);
  const [apiHealth, setApiHealth] = useState<'healthy' | 'degraded' | 'down'>('healthy');

  useEffect(() => {
    checkAPIHealth();
    const interval = setInterval(checkAPIHealth, 60000); // Check every minute
    return () => clearInterval(interval);
  }, []);

  const checkAPIHealth = async () => {
    try {
      await agriVisionAPI.getHealthStatus();
      setApiHealth('healthy');
      setIsOnline(true);
    } catch (error) {
      setApiHealth('down');
      setIsOnline(false);
    }
  };

  const withOfflineSupport = async <T>(
    apiCall: () => Promise<T>,
    fallbackData?: T,
    cacheKey?: string
  ): Promise<T> => {
    try {
      const result = await apiCall();
      // Cache successful result if cacheKey provided
      if (cacheKey) {
        // Implement your caching logic here (AsyncStorage, etc.)
      }
      return result;
    } catch (error) {
      if (!isOnline && fallbackData) {
        return fallbackData;
      }
      if (cacheKey) {
        // Try to get cached data
        // const cachedData = await getCachedData(cacheKey);
        // if (cachedData) return cachedData;
      }
      throw error;
    }
  };

  return {
    api: agriVisionAPI,
    isOnline,
    apiHealth,
    withOfflineSupport,
  };
}

// Error Boundary for AgriVision API calls
export class AgriVisionAPIError extends Error {
  constructor(
    message: string,
    public statusCode?: number,
    public endpoint?: string
  ) {
    super(message);
    this.name = 'AgriVisionAPIError';
  }
}

// Usage Example in React Native Component:
/*
import React, { useEffect, useState } from 'react';
import { View, Text, Button, Alert } from 'react-native';
import { useAgriVisionAPI, AgriVisionAPIError } from '../services/AgriVisionAPI';

export const FarmerDashboard = ({ farmerId }: { farmerId: string }) => {
  const { api, isOnline, withOfflineSupport } = useAgriVisionAPI();
  const [farmerData, setFarmerData] = useState(null);
  const [weather, setWeather] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardData();
  }, [farmerId]);

  const loadDashboardData = async () => {
    setLoading(true);
    try {
      // Load farmer profile with offline support
      const profile = await withOfflineSupport(
        () => api.getFarmerProfile(farmerId),
        null, // fallback data
        `farmer_profile_${farmerId}` // cache key
      );
      setFarmerData(profile);

      // Load weather for farmer's location
      if (profile?.location) {
        const weatherData = await withOfflineSupport(
          () => api.getWeatherForecast(profile.location.lat, profile.location.lon),
          null,
          `weather_${profile.location.lat}_${profile.location.lon}`
        );
        setWeather(weatherData);
      }
    } catch (error) {
      if (error instanceof AgriVisionAPIError) {
        Alert.alert('AgriVision Error', error.message);
      } else {
        Alert.alert('Error', 'Failed to load dashboard data');
      }
    } finally {
      setLoading(false);
    }
  };

  const sendWeatherAlert = async () => {
    try {
      await api.sendSMS(
        farmerData.phone,
        'weather_alert',
        'Heavy rain expected tomorrow'
      );
      Alert.alert('Success', 'Weather alert sent!');
    } catch (error) {
      Alert.alert('Error', 'Failed to send alert');
    }
  };

  if (loading) {
    return <Text>Loading AgriVision Dashboard...</Text>;
  }

  return (
    <View>
      <Text>Welcome to AgriVision, {farmerData?.name}!</Text>
      <Text>Connection: {isOnline ? '🟢 Online' : '🔴 Offline'}</Text>
      
      {weather && (
        <View>
          <Text>Today's Weather:</Text>
          <Text>Max: {weather.daily.temperature_2m_max[0]}°C</Text>
          <Text>Precipitation: {weather.daily.precipitation_sum[0]}mm</Text>
        </View>
      )}
      
      <Button title="Send Weather Alert" onPress={sendWeatherAlert} />
      <Button title="Refresh Data" onPress={loadDashboardData} />
    </View>
  );
};
*/
