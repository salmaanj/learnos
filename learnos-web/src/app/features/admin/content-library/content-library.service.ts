import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders,
  HttpParams
} from '@angular/common/http';
import { Observable } from 'rxjs';

export type ContentLibraryItemType =
  | 'VIDEO'
  | 'AUDIO'
  | 'PDF'
  | 'SLIDES'
  | 'DOCUMENT'
  | 'IMAGE'
  | 'LINK';

export type ContentLibraryStatus =
  | 'ACTIVE'
  | 'ARCHIVED';

export interface ContentLibraryItem {
  id: string;
  title: string;
  description: string | null;
  type: ContentLibraryItemType;
  contentUrl: string | null;
  streamingUrl: string | null;
  thumbnailUrl: string | null;
  tags: string | null;
  durationSeconds: number | null;
  fileSizeBytes: number | null;
  originalFileName: string | null;
  status: ContentLibraryStatus;
  companyId: string | null;
  companyName: string | null;
  createdByUserId: string | null;
  createdByName: string | null;
  createdAt: string | null;
  updatedAt: string | null;
}

export interface ContentLibraryPage {
  content: ContentLibraryItem[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

export interface ContentLibraryPayload {
  title: string;
  description: string | null;
  type: ContentLibraryItemType;
  contentUrl: string | null;
  streamingUrl: string | null;
  thumbnailUrl: string | null;
  tags: string | null;
  durationSeconds: number | null;
  fileSizeBytes: number | null;
  originalFileName: string | null;
  status?: ContentLibraryStatus;
  companyId: string | null;
}

@Injectable({
  providedIn: 'root'
})
export class ContentLibraryService {
  private readonly baseUrl =
    'http://localhost:8080/api/v1/content-library';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token =
      localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  getItems(options: {
    q?: string;
    type?: ContentLibraryItemType | '';
    status?: ContentLibraryStatus | '';
    page: number;
    size: number;
    sortBy?: string;
    direction?: 'ASC' | 'DESC';
  }): Observable<any> {
    let params = new HttpParams()
      .set('page', String(options.page))
      .set('size', String(options.size))
      .set('sortBy', options.sortBy || 'createdAt')
      .set('direction', options.direction || 'DESC');

    if (options.q?.trim()) {
      params = params.set('q', options.q.trim());
    }

    if (options.type) {
      params = params.set('type', options.type);
    }

    if (options.status) {
      params = params.set('status', options.status);
    }

    return this.http.get<any>(
      this.baseUrl,
      {
        headers: this.headers(),
        params
      }
    );
  }

  createItem(
    payload: ContentLibraryPayload
  ): Observable<any> {
    return this.http.post<any>(
      this.baseUrl,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  updateItem(
    id: string,
    payload: ContentLibraryPayload
  ): Observable<any> {
    return this.http.put<any>(
      `${this.baseUrl}/${id}`,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  uploadFile(
    id: string,
    file: File
  ): Observable<any> {
    const formData = new FormData();
    formData.append('file', file);

    return this.http.post<any>(
      `${this.baseUrl}/${id}/upload`,
      formData,
      {
        headers: this.headers()
      }
    );
  }

  archiveItem(id: string): Observable<any> {
    return this.http.patch<any>(
      `${this.baseUrl}/${id}/archive`,
      {},
      {
        headers: this.headers()
      }
    );
  }

  restoreItem(id: string): Observable<any> {
    return this.http.patch<any>(
      `${this.baseUrl}/${id}/restore`,
      {},
      {
        headers: this.headers()
      }
    );
  }

  deleteItem(id: string): Observable<any> {
    return this.http.delete<any>(
      `${this.baseUrl}/${id}`,
      {
        headers: this.headers()
      }
    );
  }
}