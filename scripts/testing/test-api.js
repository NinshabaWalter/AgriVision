#!/usr/bin/env node

/**
 * AgriVision API Gateway Test Suite
 * Tests all API endpoints to ensure they're working correctly
 */

const axios = require('axios');
const fs = require('fs');

const BASE_URL = 'http://localhost:3000';
const API_URL = `${BASE_URL}/api`;

// Test configuration
const TEST_CONFIG = {
  timeout: 10000,
  retries: 3,
};

// Test results
let testResults = {
  passed: 0,
  failed: 0,
  total: 0,
  details: []
};

// Utility functions
const log = (message, type = 'info') => {
  const colors = {
    info: '\x1b[36m',    // Cyan
    success: '\x1b[32m', // Green
    error: '\x1b[31m',   // Red
    warning: '\x1b[33m', // Yellow
    reset: '\x1b[0m'     // Reset
  };
  console.log(`${colors[type]}${message}${colors.reset}`);
};

const runTest = async (name, testFunction) => {
  testResults.total++;
  try {
    log(`Testing: ${name}`, 'info');
    await testFunction();
    testResults.passed++;
    testResults.details.push({ name, status: 'PASSED', error: null });
    log(`✅ ${name} - PASSED`, 'success');
  } catch (error) {
    testResults.failed++;
    testResults.details.push({ name, status: 'FAILED', error: error.message });
    log(`❌ ${name} - FAILED: ${error.message}`, 'error');
  }
};

// Test functions
const testHealthCheck = async () => {
  const response = await axios.get(`${BASE_URL}/health`, { timeout: TEST_CONFIG.timeout });
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.status) throw new Error('Health check response missing status');
};

const testWeatherAPI = async () => {
  const response = await axios.get(`${API_URL}/weather/current?lat=-1.286389&lon=36.817223`, {
    timeout: TEST_CONFIG.timeout
  });
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.current) throw new Error('Weather response missing current data');
  if (!response.data.farming_advice) throw new Error('Weather response missing farming advice');
};

const testSMSAPI = async () => {
  const response = await axios.post(`${API_URL}/sms/send`, {
    to: '+254700123456',
    message: 'Test SMS from AgriVision API',
    type: 'test'
  }, { timeout: TEST_CONFIG.timeout });
  
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.success) throw new Error('SMS response indicates failure');
};

const testBulkSMS = async () => {
  const response = await axios.post(`${API_URL}/sms/bulk`, {
    recipients: ['+254700123456', '+254700123457'],
    message: 'Bulk test SMS from AgriVision API'
  }, { timeout: TEST_CONFIG.timeout });
  
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.success) throw new Error('Bulk SMS response indicates failure');
};

const testMpesaSTKPush = async () => {
  const response = await axios.post(`${API_URL}/mpesa/stkpush`, {
    phone: '254700123456',
    amount: 100,
    account_reference: 'TEST001',
    transaction_desc: 'Test payment'
  }, { timeout: TEST_CONFIG.timeout });
  
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  // In mock mode, should return success
  if (!response.data.CheckoutRequestID) throw new Error('M-Pesa response missing CheckoutRequestID');
};

const testMarketPrices = async () => {
  const response = await axios.get(`${API_URL}/market/prices?country=kenya`, {
    timeout: TEST_CONFIG.timeout
  });
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.prices || !Array.isArray(response.data.prices)) {
    throw new Error('Market prices response missing prices array');
  }
};

const testSpecificCropPrice = async () => {
  const response = await axios.get(`${API_URL}/market/prices?country=kenya&crop=maize`, {
    timeout: TEST_CONFIG.timeout
  });
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.crop || response.data.crop !== 'maize') {
    throw new Error('Specific crop price response incorrect');
  }
};

const testPriceHistory = async () => {
  const response = await axios.get(`${API_URL}/market/history/maize?days=30`, {
    timeout: TEST_CONFIG.timeout
  });
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.history || !Array.isArray(response.data.history)) {
    throw new Error('Price history response missing history array');
  }
};

const testGeocoding = async () => {
  const response = await axios.get(`${API_URL}/geocode?address=Nairobi, Kenya`, {
    timeout: TEST_CONFIG.timeout
  });
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.results || !Array.isArray(response.data.results)) {
    throw new Error('Geocoding response missing results array');
  }
};

const testReverseGeocoding = async () => {
  const response = await axios.get(`${API_URL}/reverse-geocode?lat=-1.286389&lon=36.817223`, {
    timeout: TEST_CONFIG.timeout
  });
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.address) throw new Error('Reverse geocoding response missing address');
};

const testPushNotification = async () => {
  const response = await axios.post(`${API_URL}/notifications/send`, {
    token: 'test_firebase_token',
    title: 'Test Notification',
    body: 'This is a test notification from AgriVision API',
    data: { type: 'test' }
  }, { timeout: TEST_CONFIG.timeout });
  
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.success) throw new Error('Push notification response indicates failure');
};

const testAgoraToken = async () => {
  const response = await axios.post(`${API_URL}/agora/token`, {
    channelName: 'test_channel',
    uid: 'test_user_123',
    role: 1
  }, { timeout: TEST_CONFIG.timeout });
  
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.token) throw new Error('Agora token response missing token');
};

const testDiseaseDetection = async () => {
  // Mock base64 image data
  const mockImageBase64 = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=';
  
  const response = await axios.post(`${API_URL}/ai/detect-disease`, {
    image_base64: mockImageBase64,
    crop_type: 'maize'
  }, { timeout: 30000 }); // Longer timeout for AI processing
  
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.predictions || !Array.isArray(response.data.predictions)) {
    throw new Error('Disease detection response missing predictions array');
  }
};

const testGetExperts = async () => {
  const response = await axios.get(`${API_URL}/experts?specialty=crop_diseases&language=english`, {
    timeout: TEST_CONFIG.timeout
  });
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.experts || !Array.isArray(response.data.experts)) {
    throw new Error('Experts response missing experts array');
  }
};

const testBookConsultation = async () => {
  const response = await axios.post(`${API_URL}/experts/book`, {
    expert_id: 'exp_001',
    date: '2024-01-20',
    time: '14:00',
    duration: 30,
    topic: 'Test consultation booking'
  }, { timeout: TEST_CONFIG.timeout });
  
  if (response.status !== 200) throw new Error(`Expected 200, got ${response.status}`);
  if (!response.data.success) throw new Error('Consultation booking response indicates failure');
};

const testInvalidEndpoint = async () => {
  try {
    await axios.get(`${API_URL}/invalid-endpoint`, { timeout: TEST_CONFIG.timeout });
    throw new Error('Expected 404 error for invalid endpoint');
  } catch (error) {
    if (error.response && error.response.status === 404) {
      return; // This is expected
    }
    throw error;
  }
};

// Main test runner
const runAllTests = async () => {
  log('🌾 AgriVision API Gateway Test Suite', 'info');
  log('==========================================', 'info');
  
  // Check if server is running
  try {
    await axios.get(`${BASE_URL}/health`, { timeout: 5000 });
    log('✅ Server is running', 'success');
  } catch (error) {
    log('❌ Server is not running. Please start the API gateway first:', 'error');
    log('   npm start  or  ./start-api.sh', 'warning');
    process.exit(1);
  }
  
  log('', 'info');
  
  // Run all tests
  await runTest('Health Check', testHealthCheck);
  await runTest('Weather API', testWeatherAPI);
  await runTest('SMS API', testSMSAPI);
  await runTest('Bulk SMS API', testBulkSMS);
  await runTest('M-Pesa STK Push', testMpesaSTKPush);
  await runTest('Market Prices', testMarketPrices);
  await runTest('Specific Crop Price', testSpecificCropPrice);
  await runTest('Price History', testPriceHistory);
  await runTest('Geocoding', testGeocoding);
  await runTest('Reverse Geocoding', testReverseGeocoding);
  await runTest('Push Notifications', testPushNotification);
  await runTest('Agora Token Generation', testAgoraToken);
  await runTest('Disease Detection AI', testDiseaseDetection);
  await runTest('Get Experts', testGetExperts);
  await runTest('Book Consultation', testBookConsultation);
  await runTest('Invalid Endpoint (404)', testInvalidEndpoint);
  
  // Print summary
  log('', 'info');
  log('==========================================', 'info');
  log('📊 Test Results Summary', 'info');
  log(`Total Tests: ${testResults.total}`, 'info');
  log(`Passed: ${testResults.passed}`, 'success');
  log(`Failed: ${testResults.failed}`, testResults.failed > 0 ? 'error' : 'info');
  log(`Success Rate: ${((testResults.passed / testResults.total) * 100).toFixed(1)}%`, 
      testResults.failed === 0 ? 'success' : 'warning');
  
  // Show failed tests
  if (testResults.failed > 0) {
    log('', 'info');
    log('❌ Failed Tests:', 'error');
    testResults.details
      .filter(test => test.status === 'FAILED')
      .forEach(test => {
        log(`   • ${test.name}: ${test.error}`, 'error');
      });
  }
  
  // Save detailed results to file
  const reportFile = 'test-results.json';
  fs.writeFileSync(reportFile, JSON.stringify({
    timestamp: new Date().toISOString(),
    summary: {
      total: testResults.total,
      passed: testResults.passed,
      failed: testResults.failed,
      successRate: ((testResults.passed / testResults.total) * 100).toFixed(1)
    },
    details: testResults.details
  }, null, 2));
  
  log('', 'info');
  log(`📄 Detailed results saved to: ${reportFile}`, 'info');
  
  // Exit with appropriate code
  process.exit(testResults.failed > 0 ? 1 : 0);
};

// Handle errors
process.on('unhandledRejection', (error) => {
  log(`Unhandled error: ${error.message}`, 'error');
  process.exit(1);
});

// Run tests
if (require.main === module) {
  runAllTests();
}

module.exports = { runAllTests, testResults };