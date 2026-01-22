import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8082';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000,
});

export interface ChatMessage {
  message: string;
}

export interface ChatResponse {
  response: string;
  timestamp: string;
}

export const sendMessage = async (message: string) => {
  return api.post<ChatResponse>('/api/python/ml/chat', { message });
};

export const getHealth = async () => {
  return api.get('/api/python/health');
};

export const getData = async () => {
  return api.get('/api/python/data');
};

export default api;
