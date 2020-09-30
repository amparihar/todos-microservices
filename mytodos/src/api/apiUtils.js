//export const baseUrl = 'https://8rjrou3fe4.execute-api.ap-south-1.amazonaws.com/dev/todos/v1';

export const baseUserUrl = 'http://localhost:4096/api';
export const baseGroupUrl = 'http://localhost:5096/api';
export const baseTaskUrl = 'http://localhost:6096/api';

export async function handleResponse(response) {
  if (response.ok) {
    return response.json();
  }
  if (response.status === 400) {
    const error = await response.text();
    throw new Error(error);
  }
  throw new Error('Network response was not ok.');
}

export function handleError(error) {
  if (error.name === 'AbortError') {
    console.log('Fetch request cancelled');
  } else {
    console.error('API call failed. ' + error);
    throw error;
  }
}
