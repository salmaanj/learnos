import {
  Injectable
} from '@angular/core';

import {
  HttpClient,
  HttpParams
} from '@angular/common/http';

import {
  Observable
} from 'rxjs';

import {
  environment
} from '../../../../environments/environment';

export interface Enquiry {
  id: string;
  name: string;
  organization: string;
  email: string;
  phone: string;
  audience: string;
  subject: string;
  message: string;
  status: string;
  read: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface EnquiryPage {
  content: Enquiry[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
  first: boolean;
  last: boolean;
  empty: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class EnquiriesService {

  private readonly baseUrl =
    `${environment.apiUrl}/enquiries`;

  constructor(
    private readonly http: HttpClient
  ) {}

  list(
    page = 0,
    size = 100,
    status?: string
  ): Observable<EnquiryPage> {
    let params = new HttpParams()
      .set('page', page)
      .set('size', size);

    if (status) {
      params = params.set('status', status);
    }

    return this.http.get<EnquiryPage>(
      this.baseUrl,
      { params }
    );
  }

  updateReadState(
    id: string,
    read: boolean
  ): Observable<Enquiry> {
    const params = new HttpParams()
      .set('read', read);

    return this.http.patch<Enquiry>(
      `${this.baseUrl}/${id}/read`,
      {},
      { params }
    );
  }

    updateStatus(
    id: string,
    status: string
    ): Observable<Enquiry> {
    const params = new HttpParams()
        .set('status', status.toUpperCase());

    return this.http.patch<Enquiry>(
        `${this.baseUrl}/${id}/status`,
        {},
        { params }
    );
    }

  delete(
    id: string
  ): Observable<void> {
    return this.http.delete<void>(
      `${this.baseUrl}/${id}`
    );
  }
}