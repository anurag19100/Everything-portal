import React, { useState, useEffect, useRef } from 'react';
import {
  Box,
  Paper,
  TextField,
  IconButton,
  Typography,
  Avatar,
  CircularProgress,
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import SmartToyIcon from '@mui/icons-material/SmartToy';
import PersonIcon from '@mui/icons-material/Person';
import { useChatStore } from '../store/chatStore';
import { sendMessage } from '../services/api';

interface Message {
  id: string;
  content: string;
  sender: 'user' | 'assistant';
  timestamp: Date;
}

const ChatInterface: React.FC = () => {
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const { messages, addMessage } = useChatStore();

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSend = async () => {
    if (!input.trim() || isLoading) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      content: input,
      sender: 'user',
      timestamp: new Date(),
    };

    addMessage(userMessage);
    setInput('');
    setIsLoading(true);

    try {
      const response = await sendMessage(input);
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: response.data.response || 'I received your message!',
        sender: 'assistant',
        timestamp: new Date(),
      };
      addMessage(assistantMessage);
    } catch (error) {
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        sender: 'assistant',
        timestamp: new Date(),
      };
      addMessage(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      {/* Messages Container */}
      <Paper
        sx={{
          flex: 1,
          overflow: 'auto',
          p: 2,
          mb: 2,
          backgroundColor: '#fafafa',
        }}
        elevation={2}
      >
        {messages.length === 0 ? (
          <Box
            sx={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              height: '100%',
              color: 'text.secondary',
            }}
          >
            <SmartToyIcon sx={{ fontSize: 64, mb: 2, opacity: 0.5 }} />
            <Typography variant="h6">Start a conversation with Claude</Typography>
            <Typography variant="body2">Type a message below to begin</Typography>
          </Box>
        ) : (
          messages.map((message) => (
            <Box
              key={message.id}
              sx={{
                display: 'flex',
                mb: 2,
                flexDirection: message.sender === 'user' ? 'row-reverse' : 'row',
              }}
            >
              <Avatar
                sx={{
                  bgcolor: message.sender === 'user' ? 'primary.main' : 'secondary.main',
                  mx: 1,
                }}
              >
                {message.sender === 'user' ? <PersonIcon /> : <SmartToyIcon />}
              </Avatar>
              <Paper
                sx={{
                  p: 2,
                  maxWidth: '70%',
                  bgcolor: message.sender === 'user' ? 'primary.light' : 'background.paper',
                }}
                elevation={1}
              >
                <Typography variant="body1" sx={{ whiteSpace: 'pre-wrap' }}>
                  {message.content}
                </Typography>
                <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                  {message.timestamp.toLocaleTimeString()}
                </Typography>
              </Paper>
            </Box>
          ))
        )}
        {isLoading && (
          <Box sx={{ display: 'flex', alignItems: 'center', ml: 7 }}>
            <CircularProgress size={20} sx={{ mr: 1 }} />
            <Typography variant="body2" color="text.secondary">
              Claude is typing...
            </Typography>
          </Box>
        )}
        <div ref={messagesEndRef} />
      </Paper>

      {/* Input Container */}
      <Paper sx={{ p: 2 }} elevation={3}>
        <Box sx={{ display: 'flex', alignItems: 'center' }}>
          <TextField
            fullWidth
            multiline
            maxRows={4}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Type your message..."
            disabled={isLoading}
            variant="outlined"
            sx={{ mr: 1 }}
          />
          <IconButton
            color="primary"
            onClick={handleSend}
            disabled={!input.trim() || isLoading}
            sx={{
              bgcolor: 'primary.main',
              color: 'white',
              '&:hover': { bgcolor: 'primary.dark' },
              '&:disabled': { bgcolor: 'action.disabledBackground' },
            }}
          >
            <SendIcon />
          </IconButton>
        </Box>
      </Paper>
    </Box>
  );
};

export default ChatInterface;
