#!/usr/bin/env node

/**
 * Comprehensive API Test Suite for AgriVision API Gateway
 */

const axios = require('axios');
const fs = require('fs');

// Configuration
const BASE_URL = process.env.API_BASE_URL || 'http://localhost:3000';
const TEST_PHONE = process.env.TEST_PHONE || '+254700000000';
const TEST_EMAIL = 'test@agrivision.com';
const TEST_PASSWORD = 'testpassword123';

let authToken = null;

// Colors for console output
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  reset: '\x1b[0m',
  bold: '\x1b[1m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function logTest(testName, status, details = '') {
  const statusColor = status === 'PASS' ? 'green' : 'red';
  const statusSymbol = status === 'PASS' ? '✅' : '❌';
  log(`${statusSymbol} ${testName}: ${status}`, statusColor);
  if (details) {
    log(`   ${details}`, 'blue');
  }
}

// Test helper functions
async function makeRequest(method, endpoint, data = null, headers = {}) {
  try {
    const config = {
      method,
      url: `${BASE_URL}${endpoint}`,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      },
      timeout: 10000
    };
    
    if (data) {
      config.data = data;
    }
    
    const response = await axios(config);
    return { success: true, data: response.data, status: response.status };
  } catch (error) {
    return {
      success: false,
      error: error.response?.data || error.message,
      status: error.response?.status || 500
    };
  }
}

async function authenticatedRequest(method, endpoint, data = null) {
  const headers = authToken ? { Authorization: `Bearer ${authToken}` } : {};
  return makeRequest(method, endpoint, data, headers);
}

// Test suites
async function testHealthCheck() {
  log('\n🏥 Testing Health Check...', 'bold');
  
  const result = await makeRequest('GET', '/health');
  
  if (result.success && result.data.status === 'healthy') {
    logTest('Health Check', 'PASS', `Services: ${Object.keys(result.data.services).length}`);
    return true;
  } else {
    logTest('Health Check', 'FAIL', result.error);
    return false;
  }
}

async function testAuthentication() {
  log('\n🔐 Testing Authentication...', 'bold');
  
  // Test registration
  const registerData = {
    email: TEST_EMAIL,
    password: TEST_PASSWORD,
    name: 'Test Farmer',
    phone: TEST_PHONE,
    location: 'Nakuru, Kenya',
    farm_size: 5.5,
    crops: ['maize', 'beans']
  };
  
  const registerResult = await makeRequest('POST', '/api/auth/register', registerData);
  
  if (registerResult.success) {
    logTest('User Registration', 'PASS', `User ID: ${registerResult.data.user?.id}`);
    authToken = registerResult.data.token;
  } else {
    logTest('User Registration', 'FAIL', registerResult.error?.error || 'Unknown error');
  }
  
  // Test login with mock user
  const loginData = {
    email: 'farmer@example.com',
    password: 'password123'
  };
  
  const loginResult = await makeRequest('POST', '/api/auth/login', loginData);
  
  if (loginResult.success) {
    logTest('User Login', 'PASS', `Token received: ${!!loginResult.data.token}`);
    authToken = loginResult.data.token;
    return true;
  } else {
    logTest('User Login', 'FAIL', loginResult.error?.error || 'Unknown error');
    return false;
  }
}

async function testWeatherAPI() {
  log('\n🌤️ Testing Weather API...', 'bold');
  
  // Test current weather
  const weatherResult = await makeRequest('GET', '/api/weather/current?lat=-1.2921&lon=36.8219');
  
  if (weatherResult.success && weatherResult.data.current) {
    logTest('Current Weather', 'PASS', `Temperature: ${weatherResult.data.current.temperature}°C`);
  } else {
    logTest('Current Weather', 'FAIL', weatherResult.error?.error || 'Unknown error');
  }
  
  // Test smart weather alerts
  const alertsResult = await makeRequest('GET', '/api/weather/smart-alerts?lat=-1.2921&lon=36.8219&crops=maize,beans');
  
  if (alertsResult.success && alertsResult.data.smart_alerts) {
    logTest('Smart Weather Alerts', 'PASS', `Alerts: ${alertsResult.data.smart_alerts.length}`);
    return true;
  } else {
    logTest('Smart Weather Alerts', 'FAIL', alertsResult.error?.error || 'Unknown error');
    return false;
  }
}

async function testAIFeatures() {
  log('\n🤖 Testing AI Features...', 'bold');
  
  // Test yield prediction
  const yieldData = {
    crop_type: 'maize',
    farm_size: 5.5,
    planting_date: '2024-03-15T00:00:00Z',
    location: 'Nakuru, Kenya',
    farming_practices: {
      irrigation: true,
      fertilizer_use: true,
      pest_control: true,
      certified_seeds: true
    }
  };
  
  const yieldResult = await makeRequest('POST', '/api/ai/yield-prediction', yieldData);
  
  if (yieldResult.success && yieldResult.data.predicted_yield) {
    logTest('Yield Prediction', 'PASS', `Predicted: ${yieldResult.data.predicted_yield.amount} bags`);
    return true;
  } else {
    logTest('Yield Prediction', 'FAIL', yieldResult.error?.error || 'Unknown error');
    return false;
  }
}

async function testMarketIntelligence() {
  log('\n📊 Testing Market Intelligence...', 'bold');
  
  // Test market intelligence
  const marketResult = await makeRequest('GET', '/api/market/intelligence?location=Nakuru&crop=maize&radius=50');
  
  if (marketResult.success && marketResult.data.markets) {
    logTest('Market Intelligence', 'PASS', `Markets found: ${marketResult.data.markets.length}`);
  } else {
    logTest('Market Intelligence', 'FAIL', marketResult.error?.error || 'Unknown error');
  }
  
  // Test current prices
  const pricesResult = await makeRequest('GET', '/api/market/prices?crop=maize&location=Kenya');
  
  if (pricesResult.success && pricesResult.data.prices) {
    logTest('Market Prices', 'PASS', `Maize price: ${pricesResult.data.prices.maize?.current} KES`);
    return true;
  } else {
    logTest('Market Prices', 'FAIL', pricesResult.error?.error || 'Unknown error');
    return false;
  }
}

async function testSMSFeatures() {
  log('\n📱 Testing SMS Features...', 'bold');
  
  // Test SMS templates
  const templatesResult = await makeRequest('GET', '/api/sms/templates?language=english&category=weather_alerts');
  
  if (templatesResult.success && templatesResult.data.templates) {
    logTest('SMS Templates', 'PASS', `Templates available: ${Object.keys(templatesResult.data.templates).length}`);
  } else {
    logTest('SMS Templates', 'FAIL', templatesResult.error?.error || 'Unknown error');
  }
  
  // Test send SMS
  const smsData = {
    to: TEST_PHONE,
    message: 'Test message from AgriVision API',
    type: 'alert'
  };
  
  const smsResult = await makeRequest('POST', '/api/sms/send', smsData);
  
  if (smsResult.success) {
    logTest('Send SMS', 'PASS', `Message ID: ${smsResult.data.messageId}`);
    return true;
  } else {
    logTest('Send SMS', 'FAIL', smsResult.error?.error || 'Unknown error');
    return false;
  }
}

async function testMpesaIntegration() {
  log('\n💰 Testing M-Pesa Integration...', 'bold');
  
  // Test STK Push
  const stkData = {
    phone: TEST_PHONE,
    amount: 100,
    account_reference: 'TEST_PAYMENT',
    transaction_desc: 'Test payment for AgriVision services'
  };
  
  const stkResult = await makeRequest('POST', '/api/mpesa/stkpush', stkData);
  
  if (stkResult.success) {
    logTest('M-Pesa STK Push', 'PASS', `Checkout ID: ${stkResult.data.CheckoutRequestID}`);
  } else {
    logTest('M-Pesa STK Push', 'FAIL', stkResult.error?.error || 'Unknown error');
  }
  
  // Test transaction history (requires authentication)
  if (authToken) {
    const transactionsResult = await authenticatedRequest('GET', '/api/mpesa/transactions');
    
    if (transactionsResult.success) {
      logTest('M-Pesa Transactions', 'PASS', `Transactions: ${transactionsResult.data.transactions?.length || 0}`);
      return true;
    } else {
      logTest('M-Pesa Transactions', 'FAIL', transactionsResult.error?.error || 'Unknown error');
      return false;
    }
  } else {
    logTest('M-Pesa Transactions', 'SKIP', 'No auth token available');
    return false;
  }
}

async function testCommunityFeatures() {
  log('\n👥 Testing Community Features...', 'bold');
  
  // Test get community posts
  const postsResult = await makeRequest('GET', '/api/community/posts?category=pest_control&page=1&limit=10');
  
  if (postsResult.success && postsResult.data.posts) {
    logTest('Community Posts', 'PASS', `Posts: ${postsResult.data.posts.length}`);
  } else {
    logTest('Community Posts', 'FAIL', postsResult.error?.error || 'Unknown error');
  }
  
  // Test share knowledge (requires authentication)
  if (authToken) {
    const shareData = {
      title: 'Test Knowledge Share',
      content: 'This is a test post about farming techniques.',
      category: 'general',
      crops: ['maize']
    };
    
    const shareResult = await authenticatedRequest('POST', '/api/community/share', shareData);
    
    if (shareResult.success) {
      logTest('Knowledge Sharing', 'PASS', `Post ID: ${shareResult.data.post?.id}`);
      return true;
    } else {
      logTest('Knowledge Sharing', 'FAIL', shareResult.error?.error || 'Unknown error');
      return false;
    }
  } else {
    logTest('Knowledge Sharing', 'SKIP', 'No auth token available');
    return false;
  }
}

async function testAnalytics() {
  log('\n📈 Testing Analytics...', 'bold');
  
  if (!authToken) {
    logTest('Analytics Tests', 'SKIP', 'No auth token available');
    return false;
  }
  
  // Test revenue analytics
  const revenueResult = await authenticatedRequest('GET', '/api/analytics/revenue?period=month&crop=maize');
  
  if (revenueResult.success && revenueResult.data.total_revenue !== undefined) {
    logTest('Revenue Analytics', 'PASS', `Revenue: $${revenueResult.data.total_revenue}`);
  } else {
    logTest('Revenue Analytics', 'FAIL', revenueResult.error?.error || 'Unknown error');
  }
  
  // Test sustainability scoring
  const sustainabilityResult = await authenticatedRequest('GET', '/api/analytics/sustainability');
  
  if (sustainabilityResult.success && sustainabilityResult.data.overall_score !== undefined) {
    logTest('Sustainability Scoring', 'PASS', `Score: ${sustainabilityResult.data.overall_score}/10`);
    return true;
  } else {
    logTest('Sustainability Scoring', 'FAIL', sustainabilityResult.error?.error || 'Unknown error');
    return false;
  }
}

async function testCooperativeFeatures() {
  log('\n🤝 Testing Cooperative Features...', 'bold');
  
  if (!authToken) {
    logTest('Cooperative Tests', 'SKIP', 'No auth token available');
    return false;
  }
  
  // Test get cooperative info
  const coopId = 'coop_123';
  const coopResult = await authenticatedRequest('GET', `/api/cooperatives/${coopId}`);
  
  if (coopResult.success) {
    logTest('Get Cooperative Info', 'PASS', `Members: ${coopResult.data.cooperative?.member_count}`);
  } else {
    logTest('Get Cooperative Info', 'FAIL', coopResult.error?.error || 'Unknown error');
  }
  
  // Test user cooperatives
  const userCoopsResult = await authenticatedRequest('GET', '/api/cooperatives/user/cooperatives');
  
  if (userCoopsResult.success) {
    logTest('User Cooperatives', 'PASS', `Cooperatives: ${userCoopsResult.data.cooperatives?.length || 0}`);
    return true;
  } else {
    logTest('User Cooperatives', 'FAIL', userCoopsResult.error?.error || 'Unknown error');
    return false;
  }
}

async function testPerformance() {
  log('\n⚡ Testing Performance...', 'bold');
  
  const startTime = Date.now();
  const promises = [];
  
  // Make 10 concurrent requests to health endpoint
  for (let i = 0; i < 10; i++) {
    promises.push(makeRequest('GET', '/health'));
  }
  
  try {
    const results = await Promise.all(promises);
    const endTime = Date.now();
    const duration = endTime - startTime;
    const successCount = results.filter(r => r.success).length;
    
    logTest('Concurrent Requests', 'PASS', `${successCount}/10 successful in ${duration}ms`);
    return true;
  } catch (error) {
    logTest('Performance Tests', 'FAIL', error.message);
    return false;
  }
}

async function testSecurity() {
  log('\n🔒 Testing Security...', 'bold');
  
  // Test protected endpoint without auth
  const protectedResult = await makeRequest('GET', '/api/analytics/revenue');
  
  if (protectedResult.status === 401) {
    logTest('Authentication Protection', 'PASS', 'Protected endpoint requires auth');
  } else {
    logTest('Authentication Protection', 'FAIL', 'Protected endpoint accessible without auth');
  }
  
  // Test input validation
  const invalidData = {
    email: 'invalid-email',
    password: '123' // Too short
  };
  
  const validationResult = await makeRequest('POST', '/api/auth/register', invalidData);
  
  if (validationResult.status === 400) {
    logTest('Input Validation', 'PASS', 'Invalid input rejected');
    return true;
  } else {
    logTest('Input Validation', 'FAIL', 'Invalid input accepted');
    return false;
  }
}

// Main test runner
async function runAllTests() {
  log('🌾 AgriVision API Gateway Test Suite', 'bold');
  log('=====================================', 'blue');
  
  const testResults = [];
  
  // Run all test suites
  testResults.push(await testHealthCheck());
  testResults.push(await testAuthentication());
  testResults.push(await testWeatherAPI());
  testResults.push(await testAIFeatures());
  testResults.push(await testMarketIntelligence());
  testResults.push(await testSMSFeatures());
  testResults.push(await testMpesaIntegration());
  testResults.push(await testCommunityFeatures());
  testResults.push(await testAnalytics());
  testResults.push(await testCooperativeFeatures());
  testResults.push(await testPerformance());
  testResults.push(await testSecurity());
  
  // Summary
  const passedTests = testResults.filter(result => result === true).length;
  const totalTests = testResults.length;
  
  log('\n📊 Test Summary', 'bold');
  log('===============', 'blue');
  log(`Total Tests: ${totalTests}`, 'blue');
  log(`Passed: ${passedTests}`, 'green');
  log(`Failed: ${totalTests - passedTests}`, 'red');
  log(`Success Rate: ${((passedTests / totalTests) * 100).toFixed(1)}%`, 'yellow');
  
  if (passedTests === totalTests) {
    log('\n🎉 All tests passed! API Gateway is ready for production.', 'green');
  } else {
    log('\n⚠️ Some tests failed. Please check the API Gateway configuration.', 'yellow');
  }
  
  return passedTests === totalTests;
}

// Run tests if this file is executed directly
if (require.main === module) {
  runAllTests().then(success => {
    process.exit(success ? 0 : 1);
  }).catch(error => {
    log(`\n❌ Test suite failed with error: ${error.message}`, 'red');
    process.exit(1);
  });
}

module.exports = {
  runAllTests,
  testHealthCheck,
  testAuthentication,
  testWeatherAPI,
  testAIFeatures,
  testMarketIntelligence,
  testSMSFeatures,
  testMpesaIntegration,
  testCommunityFeatures,
  testAnalytics,
  testCooperativeFeatures,
  testPerformance,
  testSecurity
};