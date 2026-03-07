SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE public.departments (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE SEQUENCE public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;

CREATE TABLE public.employees (
    id bigint NOT NULL,
    name character varying,
    department_id bigint NOT NULL,
    salary integer,
    hire_date date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE SEQUENCE public.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2026-02-26 17:25:13.328177	2026-02-26 17:25:13.328182
\.

COPY public.departments (id, name, created_at, updated_at) FROM stdin;
1	Engineering	2026-02-26 17:33:58.343907	2026-02-26 17:33:58.343907
2	Marketing	2026-02-26 17:33:58.394128	2026-02-26 17:33:58.394128
3	Sales	2026-02-26 17:33:58.413814	2026-02-26 17:33:58.413814
\.

COPY public.employees (id, name, department_id, salary, hire_date, created_at, updated_at) FROM stdin;
1	Alice	1	95000	2019-01-15	2026-02-26 17:33:58.467483	2026-02-26 17:33:58.467483
2	Bob	1	80000	2020-03-10	2026-02-26 17:33:58.484962	2026-02-26 17:33:58.484962
3	Carol	1	80000	2021-06-01	2026-02-26 17:33:58.50523	2026-02-26 17:33:58.50523
4	Dave	1	70000	2022-09-20	2026-02-26 17:33:58.518147	2026-02-26 17:33:58.518147
5	Eve	2	75000	2018-11-05	2026-02-26 17:33:58.535133	2026-02-26 17:33:58.535133
6	Frank	2	72000	2020-07-22	2026-02-26 17:33:58.551385	2026-02-26 17:33:58.551385
7	Grace	2	68000	2021-12-01	2026-02-26 17:33:58.567999	2026-02-26 17:33:58.567999
8	Hank	3	60000	2019-05-18	2026-02-26 17:33:58.601792	2026-02-26 17:33:58.601792
9	Ivy	3	65000	2020-02-14	2026-02-26 17:33:58.618593	2026-02-26 17:33:58.618593
10	Jack	3	62000	2023-01-10	2026-02-26 17:33:58.635683	2026-02-26 17:33:58.635683
\.

COPY public.schema_migrations (version) FROM stdin;
20260226173237
20260226173246
\.

SELECT pg_catalog.setval('public.departments_id_seq', 3, true);

SELECT pg_catalog.setval('public.employees_id_seq', 10, true);

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

CREATE INDEX index_employees_on_department_id ON public.employees USING btree (department_id);

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_0025f65a97 FOREIGN KEY (department_id) REFERENCES public.departments(id);