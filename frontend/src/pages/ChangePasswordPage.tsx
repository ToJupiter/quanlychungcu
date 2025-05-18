// src/pages/ChangePasswordPage.tsx
import React, { useState,  } from 'react';
import type {FormEvent} from 'react';
import apiClient from '../api/apiClient';
import { AxiosError } from 'axios';
import type { ApiErrorResponse } from '../types';

const ChangePasswordPage: React.FC = () => {
  const [old_password, setOldPassword] = useState('');
  const [new_password, setNewPassword] = useState('');
  const [confirm_new_password, setConfirmNewPassword] = useState('');
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setMessage(null);
    setIsLoading(true);

    if (new_password !== confirm_new_password) {
      setError("New passwords do not match.");
      setIsLoading(false);
      return;
    }
    if (new_password.length < 8) {
      setError("New password must be at least 8 characters long.");
      setIsLoading(false);
      return;
    }

    try {
      await apiClient.post('/auth/staff/change-password', {
        old_password,
        new_password,
      });
      setMessage('Password changed successfully!');
      setOldPassword('');
      setNewPassword('');
      setConfirmNewPassword('');
    } catch (err) {
      const axiosError = err as AxiosError<ApiErrorResponse>;
      if (axiosError.response && axiosError.response.data) {
        setError(axiosError.response.data.message || 'Failed to change password.');
      } else {
        setError('An unexpected error occurred.');
      }
      console.error('Change password error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '500px', margin: '50px auto' }}>
      <h1>Change Password</h1>
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="old_password">Old Password:</label>
          <input
            type="password"
            id="old_password"
            value={old_password}
            onChange={(e) => setOldPassword(e.target.value)}
            required
            disabled={isLoading}
          />
        </div>
        <div>
          <label htmlFor="new_password">New Password:</label>
          <input
            type="password"
            id="new_password"
            value={new_password}
            onChange={(e) => setNewPassword(e.target.value)}
            required
            disabled={isLoading}
          />
        </div>
        <div>
          <label htmlFor="confirm_new_password">Confirm New Password:</label>
          <input
            type="password"
            id="confirm_new_password"
            value={confirm_new_password}
            onChange={(e) => setConfirmNewPassword(e.target.value)}
            required
            disabled={isLoading}
          />
        </div>
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'Changing...' : 'Change Password'}
        </button>
        {error && <p className="error-message">{error}</p>}
        {message && <p className="success-message">{message}</p>}
      </form>
    </div>
  );
};

export default ChangePasswordPage;