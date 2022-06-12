import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const {
  POSTGRES_READ_USER,
  POSTGRES_CREATE_USER,
  POSTGRES_UPDATE_USER,
  POSTGRES_DELETE_USER,
  POSTGRES_CRUD_USER,
  POSTGRES_READ_USER_PASSWORD,
  POSTGRES_CREATE_USER_PASSWORD,
  POSTGRES_DELETE_USER_PASSWORD,
  POSTGRES_UPDATE_USER_PASSWORD,
  POSTGRES_CRUD_USER_PASSWORD,
  POSTGRES_ENDPOINT,
  POSTGRES_ENDPOINT_DEV,
  POSTGRES_PORT,
  POSTGRES_DB,
  POSTGRES_DB_DEV,
  NODE_ENV,
} = process.env;

const PRODUCTION_ENV = NODE_ENV === 'production';

// **** POOL PERMISSIONS ****

const EndPoint = PRODUCTION_ENV ? POSTGRES_ENDPOINT : POSTGRES_ENDPOINT_DEV;
const database = PRODUCTION_ENV ? POSTGRES_DB : POSTGRES_DB_DEV;
const port = Number(POSTGRES_PORT);

export const ReadPool = new Pool({
  host: EndPoint,
  port,
  database,
  user: POSTGRES_READ_USER,
  password: POSTGRES_READ_USER_PASSWORD,
  max: 20,
});

export const CreatePool = new Pool({
  host: EndPoint,
  port,
  database,
  user: POSTGRES_CREATE_USER,
  password: POSTGRES_CREATE_USER_PASSWORD,
  max: 10,
});

export const UpdatePool = new Pool({
  host: EndPoint,
  port,
  database,
  user: POSTGRES_UPDATE_USER,
  password: POSTGRES_UPDATE_USER_PASSWORD,
  max: 10,
});

export const DeletePool = new Pool({
  host: EndPoint,
  port,
  database,
  user: POSTGRES_DELETE_USER,
  password: POSTGRES_DELETE_USER_PASSWORD,
  max: 10,
});

export const CRUDPool = new Pool({
  host: EndPoint,
  port,
  database,
  user: POSTGRES_CRUD_USER,
  password: POSTGRES_CRUD_USER_PASSWORD,
  max: 10,
});
