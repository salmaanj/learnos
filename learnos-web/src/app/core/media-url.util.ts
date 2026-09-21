const API_BASE_URL = 'http://localhost:8080';
const API_CONTEXT_PATH = '/api/v1';

export function resolveMediaUrl(
  rawUrl: string | null | undefined
): string | null {
  if (rawUrl === null || rawUrl === undefined) {
    return null;
  }

  const value = String(rawUrl).trim();

  if (!value) {
    return null;
  }

  if (
    value.startsWith('blob:') ||
    value.startsWith('data:')
  ) {
    return value;
  }

  if (
    value.startsWith('http://') ||
    value.startsWith('https://')
  ) {
    return value;
  }

  const filesIndex = value.indexOf('/files/');

  if (filesIndex >= 0) {
    const filePath = value.substring(filesIndex);

    return `${API_BASE_URL}${API_CONTEXT_PATH}${filePath}`;
  }

  if (value.startsWith('/api/v1/')) {
    return `${API_BASE_URL}${value}`;
  }

  if (value.startsWith('/')) {
    return `${API_BASE_URL}${API_CONTEXT_PATH}${value}`;
  }

  return `${API_BASE_URL}${API_CONTEXT_PATH}/${value}`;
}