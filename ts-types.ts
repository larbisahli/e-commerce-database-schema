// CUSTOMER PRIVILEGES
export enum INTERNAL_PRIVILEGES {
  READ = 'read_privilege',
  CREATE = 'create_privilege',
  UPDATE = 'update_privilege',
  DELETE = 'delete_privilege',
}

// STAFF PRIVILEGES
export enum STAFF_PRIVILEGES {
  READ = 'staff_read_privilege',
  CREATE = 'staff_create_privilege',
  UPDATE = 'staff_update_privilege',
  DELETE = 'staff_delete_privilege',
}

// ADMIN PRIVILEGES
export enum ADMIN_PRIVILEGES {
  READ = 'admin_read_privilege',
  CREATE = 'admin_create_privilege',
  UPDATE = 'admin_update_privilege',
  DELETE = 'admin_delete_privilege',
  SUPER = 'super_admin_privilege',
}

export enum SortOrder {
  Asc = 'ASC',
  Desc = 'DESC',
}

export enum OrderBy {
  CREATED_AT = 'created_at',
  UPDATED_AT = 'updated_at',
}

export enum SortOrder {
  /** Sort records in ascending order. */
  Asc = 'ASC',
  /** Sort records in descending order. */
  Desc = 'DESC',
}

export enum OrderBy {
  CREATED_AT = 'created_at',
  UPDATED_AT = 'updated_at',
}

export enum CouponDiscountsType {
  Fixed = 'fixed',
  Percentage = 'percentage',
  FreeShipping = 'free_shipping',
}

// Nullable can be assigned to a value or can be assigned to null.
export declare type Nullable<T> = T | null;

/** Built-in and custom scalars are mapped to their actual values */
export declare type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  SortOrder: SortOrder.Asc | SortOrder.Desc;
  /** A datetime string with format `Y-m-d H:i:s`, e.g. `2018-05-23 13:43:32`. */
  DateTime: string | number | Date;
  Mixed: string | number | Date;
  Upload: string | number | Date;
  /** A date string with format `Y-m-d`, e.g. `2011-05-23`. */
  Date: string | number | Date;
  /** A datetime and timezone string in ISO 8601 format `Y-m-dTH:i:sO`, e.g. `2020-04-20T13:53:12+02:00`. */
  DateTimeTz: string | number | Date;
};

export type PrivilegesType = (
  | typeof INTERNAL_PRIVILEGES.READ
  | typeof INTERNAL_PRIVILEGES.CREATE
  | typeof INTERNAL_PRIVILEGES.DELETE
  | typeof INTERNAL_PRIVILEGES.UPDATE
  | typeof STAFF_PRIVILEGES.READ
  | typeof STAFF_PRIVILEGES.CREATE
  | typeof STAFF_PRIVILEGES.UPDATE
  | typeof STAFF_PRIVILEGES.DELETE
  | typeof ADMIN_PRIVILEGES.READ
  | typeof ADMIN_PRIVILEGES.CREATE
  | typeof ADMIN_PRIVILEGES.UPDATE
  | typeof ADMIN_PRIVILEGES.DELETE
  | typeof ADMIN_PRIVILEGES.SUPER
)[];
  
export type ActionsType = [
  (
    | typeof INTERNAL_PRIVILEGES.READ
    | typeof INTERNAL_PRIVILEGES.CREATE
    | typeof INTERNAL_PRIVILEGES.DELETE
    | typeof INTERNAL_PRIVILEGES.UPDATE
    | typeof STAFF_PRIVILEGES.READ
    | typeof STAFF_PRIVILEGES.CREATE
    | typeof STAFF_PRIVILEGES.UPDATE
    | typeof STAFF_PRIVILEGES.DELETE
    | typeof ADMIN_PRIVILEGES.READ
    | typeof ADMIN_PRIVILEGES.CREATE
    | typeof ADMIN_PRIVILEGES.UPDATE
    | typeof ADMIN_PRIVILEGES.DELETE
  ),
  typeof ADMIN_PRIVILEGES.SUPER?
];
  
// -----


interface SharedValues {
  created_at?: Nullable<Scalars['DateTimeTz']>;
  updated_at?: Nullable<Scalars['DateTimeTz']>;
  created_by?: Nullable<{
    id: Scalars['ID'];
    first_name?: Scalars['String'];
    last_name?: Scalars['String'];
    profile?: IMGType;
  }>;
  updated_by?: Nullable<{
    id: Scalars['ID'];
    first_name?: Scalars['String'];
    last_name?: Scalars['String'];
    profile?: IMGType;
  }>;
  // extra
  page: Nullable<Scalars['Int']>;
  limit: Nullable<Scalars['Int']>;
  orderBy: OrderBy;
  sortedBy: SortOrder;
  count: number;
}

export interface CategoryType extends SharedValues {
  id: Scalars['ID'];
  parent_id?: Nullable<Scalars['ID']>;
  category_name: Scalars['String'];
  category_description?: Nullable<Scalars['String']>;
  active?: Scalars['Boolean'];
  icon?: Scalars['String'];
  thumbnail?: IMGType;
  has_children?: Scalars['Boolean'];
}

export interface AttributesType extends SharedValues {
  id?: string;
  attribute_name?: string;
  attribute_values?: AttributeValuesType[];
}

export interface ShippingType extends SharedValues {
  id?: string;
  shipper_name?: string;
  active?: boolean;
  thumbnail?: IMGType;
}

export interface AttributeValuesType {
  id?: string;
  attribute_id?: string;
  attribute_value?: string;
  color?: string;
}

export interface TagType extends SharedValues {
  id?: string;
  tag_name?: string;
  icon?: string;
}

export interface OrderStatusType extends SharedValues {
  id?: string;
  status_name?: string;
  color?: string;
  privacy?: string;
}

export interface CouponType extends SharedValues {
  id?: Nullable<Scalars['ID']>;
  code?: Nullable<Scalars['String']>;
  discount_value?: Scalars['Int'];
  order_amount_limit?: Scalars['Int'];
  discount_type?: CouponDiscountsType;
  image_path?: Nullable<Scalars['String']>;
  times_used?: Nullable<Scalars['Int']>;
  max_usage?: Nullable<Scalars['Int']>;
  coupon_start_date?: Nullable<Scalars['Date']>;
  coupon_end_date?: Nullable<Scalars['Date']>;
}

export interface ProductType extends SharedValues {
  id: Scalars['ID'];
  slug: Scalars['String'];
  product_name: Scalars['String'];
  sku?: Nullable<Scalars['String']>;
  sale_price?: Scalars['Float'];
  compare_price?: Scalars['Float'];
  buying_price?: Scalars['Float'];
  max_price?: Scalars['Float'];
  min_price?: Scalars['Float'];
  quantity?: Scalars['Int'];
  short_description?: Nullable<Scalars['String']>;
  product_description?: Scalars['String'];
  published?: Scalars['Boolean'];
  status?: 'draft' | 'publish';
  disable_out_of_stock?: Scalars['Boolean'];
  note?: Nullable<Scalars['String']>;
  thumbnail?: IMGType;
  gallery?: IMGType[];
  categories?: Array<CategoryType>;
  suppliers?: Nullable<Array<Nullable<SuppliersType>>>;
  tags?: Nullable<Array<Nullable<TagType>>>;
  shippings?: Nullable<Array<Nullable<ProductShippings>>>;
  product_shipping_info?: ProductShippingInfo;
  variation_options: ProductVariationOptions[];
  variations?: {
    attribute: AttributesType;
    attribute_values: Array<Nullable<AttributeValuesType>>;
  }[];
  // [key: string]: any;
}

export interface ProductVariationOptions {
  id: string;
  title: string;
  is_disable: boolean;
  active: boolean;
  image: string;
  options: string[];
  sale_price: Scalars['Float'];
  compare_price: Scalars['Float'];
  buying_price: Scalars['Float'];
  quantity: Scalars['Int'];
  sku: Scalars['String'];
}

export interface IMGType {
  id: Scalars['String'];
  image: Scalars['String'];
  placeholder: Scalars['String'];
  is_thumbnail: boolean;
}

export interface ProductShippings {
  shipping_zones?: {
    zones: { name: string; code: string }[];
    shipping_price?: Scalars['Float'];
  }[];
  shipping_provider?: Shipping;
}

export interface Shipping extends SharedValues {
  id?: Nullable<Scalars['ID']>;
  shipper_name?: Nullable<Scalars['String']>;
  active?: Nullable<Scalars['Boolean']>;
  thumbnail?: IMGType;
}
export interface ProductShippingInfo {
  id?: Scalars['ID'];
  product_id?: Scalars['ID'];
  weight?: Scalars['Int'];
  weight_unit?: Scalars['String'];
  volume?: Scalars['Int'];
  volume_unit?: Scalars['String'];
  dimension_width?: Scalars['Int'];
  dimension_height?: Scalars['Int'];
  dimension_depth?: Scalars['Int'];
  dimension_unit?: Scalars['String'];
}

export interface StaffAccountType extends SharedValues {
  id: string;
  first_name: string;
  last_name: string;
  phone_number: string | null;
  email: string;
  password_hash: string;
  password: string;
  active: boolean;
  profile: IMGType;
  role?: RoleInterfaceType;
  role_id?: number;
  // privileges: string[];
}

export interface RoleInterfaceType {
  id: number;
  role_name: string;
  privileges: PrivilegesType;
}

export interface LoginType {
  email: string;
  password: string;
  remember_me: boolean;
  store_name: string;
}

export interface SuppliersType extends SharedValues {
  id?: Scalars['ID'];
  supplier_name?: Scalars['String'];
  company?: Nullable<Scalars['String']>;
  phone_number?: Nullable<Scalars['String']>;
  dial_code?: Nullable<Scalars['String']>;
  address_line1?: Scalars['String'];
  address_line2?: Nullable<Scalars['String']>;
  country?: Nullable<Scalars['String']>;
  city?: Nullable<Scalars['String']>;
  note?: Nullable<Scalars['String']>;
}
 
  
