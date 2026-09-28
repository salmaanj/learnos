export interface Role {
  id: string;
  name: string;
  description: string | null;
  systemRole: boolean;
  permissions: string[];
}

export interface Permission {
  id: string;
  code: string;
  description: string | null;
}

export interface RoleRequest {
  name: string;
  description: string;
  permissionIds: string[];
}