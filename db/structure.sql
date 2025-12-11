\restrict 9F9eemyHPhIZvy2Po1eEbSVKmoueh1OQDg6phdLClqzRm2yP8OfPRxDYsSHvjtE

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

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

--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ad_impressions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_impressions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    placement character varying NOT NULL,
    clicked boolean DEFAULT false NOT NULL,
    revenue numeric(10,4) DEFAULT 0.0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ad_impressions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ad_impressions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ad_impressions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ad_impressions_id_seq OWNED BY public.ad_impressions.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: outfit_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outfit_items (
    id bigint NOT NULL,
    outfit_id bigint NOT NULL,
    wardrobe_item_id bigint NOT NULL,
    position_x double precision,
    position_y double precision,
    scale double precision,
    rotation double precision,
    z_index integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: outfit_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outfit_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outfit_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outfit_items_id_seq OWNED BY public.outfit_items.id;


--
-- Name: outfit_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outfit_suggestions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    context text NOT NULL,
    gemini_response jsonb,
    validated_suggestions jsonb DEFAULT '[]'::jsonb,
    suggestions_count integer DEFAULT 0,
    api_cost numeric(10,4) DEFAULT 0.0,
    response_time_ms integer,
    status character varying DEFAULT 'pending'::character varying,
    error_message text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: outfit_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outfit_suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outfit_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outfit_suggestions_id_seq OWNED BY public.outfit_suggestions.id;


--
-- Name: outfits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outfits (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying,
    metadata jsonb,
    last_worn_at timestamp(6) without time zone,
    favorite boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: outfits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outfits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outfits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outfits_id_seq OWNED BY public.outfits.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    stripe_subscription_id character varying,
    stripe_customer_id character varying,
    stripe_price_id character varying,
    status integer DEFAULT 0,
    current_period_start timestamp(6) without time zone,
    current_period_end timestamp(6) without time zone,
    cancel_at_period_end boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_profiles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    style_preference integer,
    body_type integer,
    age_range character varying,
    location character varying,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_profiles_id_seq OWNED BY public.user_profiles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    jti character varying DEFAULT ''::character varying NOT NULL,
    ai_suggestions_today integer DEFAULT 0,
    ai_suggestions_reset_at date,
    subscription_tier character varying DEFAULT 'free'::character varying,
    location character varying,
    admin boolean DEFAULT false NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: wardrobe_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wardrobe_items (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    category character varying,
    color character varying,
    metadata jsonb,
    embedding public.vector(768),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: wardrobe_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wardrobe_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wardrobe_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wardrobe_items_id_seq OWNED BY public.wardrobe_items.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: ad_impressions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_impressions ALTER COLUMN id SET DEFAULT nextval('public.ad_impressions_id_seq'::regclass);


--
-- Name: outfit_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfit_items ALTER COLUMN id SET DEFAULT nextval('public.outfit_items_id_seq'::regclass);


--
-- Name: outfit_suggestions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfit_suggestions ALTER COLUMN id SET DEFAULT nextval('public.outfit_suggestions_id_seq'::regclass);


--
-- Name: outfits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfits ALTER COLUMN id SET DEFAULT nextval('public.outfits_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: user_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles ALTER COLUMN id SET DEFAULT nextval('public.user_profiles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wardrobe_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wardrobe_items ALTER COLUMN id SET DEFAULT nextval('public.wardrobe_items_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ad_impressions ad_impressions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_impressions
    ADD CONSTRAINT ad_impressions_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: outfit_items outfit_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfit_items
    ADD CONSTRAINT outfit_items_pkey PRIMARY KEY (id);


--
-- Name: outfit_suggestions outfit_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfit_suggestions
    ADD CONSTRAINT outfit_suggestions_pkey PRIMARY KEY (id);


--
-- Name: outfits outfits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfits
    ADD CONSTRAINT outfits_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wardrobe_items wardrobe_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wardrobe_items
    ADD CONSTRAINT wardrobe_items_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_ad_impressions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ad_impressions_on_created_at ON public.ad_impressions USING btree (created_at);


--
-- Name: index_ad_impressions_on_placement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ad_impressions_on_placement ON public.ad_impressions USING btree (placement);


--
-- Name: index_ad_impressions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ad_impressions_on_user_id ON public.ad_impressions USING btree (user_id);


--
-- Name: index_ad_impressions_on_user_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ad_impressions_on_user_id_and_created_at ON public.ad_impressions USING btree (user_id, created_at);


--
-- Name: index_outfit_items_on_outfit_and_wardrobe_item; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfit_items_on_outfit_and_wardrobe_item ON public.outfit_items USING btree (outfit_id, wardrobe_item_id);


--
-- Name: INDEX index_outfit_items_on_outfit_and_wardrobe_item; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.index_outfit_items_on_outfit_and_wardrobe_item IS 'Prevents duplicate items in outfits, speeds up lookups';


--
-- Name: index_outfit_items_on_outfit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfit_items_on_outfit_id ON public.outfit_items USING btree (outfit_id);


--
-- Name: index_outfit_items_on_wardrobe_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfit_items_on_wardrobe_item_id ON public.outfit_items USING btree (wardrobe_item_id);


--
-- Name: index_outfit_suggestions_on_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfit_suggestions_on_context ON public.outfit_suggestions USING hash (context);


--
-- Name: index_outfit_suggestions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfit_suggestions_on_created_at ON public.outfit_suggestions USING btree (created_at);


--
-- Name: index_outfit_suggestions_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfit_suggestions_on_status ON public.outfit_suggestions USING btree (status);


--
-- Name: index_outfit_suggestions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfit_suggestions_on_user_id ON public.outfit_suggestions USING btree (user_id);


--
-- Name: index_outfit_suggestions_on_user_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfit_suggestions_on_user_id_and_created_at ON public.outfit_suggestions USING btree (user_id, created_at);


--
-- Name: index_outfits_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfits_on_created_at ON public.outfits USING btree (created_at);


--
-- Name: index_outfits_on_favorite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfits_on_favorite ON public.outfits USING btree (favorite) WHERE (favorite = true);


--
-- Name: INDEX index_outfits_on_favorite; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.index_outfits_on_favorite IS 'Partial index for filtering favorite outfits';


--
-- Name: index_outfits_on_favorite_true; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfits_on_favorite_true ON public.outfits USING btree (favorite) WHERE (favorite = true);


--
-- Name: index_outfits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outfits_on_user_id ON public.outfits USING btree (user_id);


--
-- Name: index_subscriptions_on_stripe_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_stripe_customer_id ON public.subscriptions USING btree (stripe_customer_id);


--
-- Name: index_subscriptions_on_stripe_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscriptions_on_stripe_subscription_id ON public.subscriptions USING btree (stripe_subscription_id);


--
-- Name: index_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscriptions_on_user_id ON public.subscriptions USING btree (user_id);


--
-- Name: index_user_profiles_on_body_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_body_type ON public.user_profiles USING btree (body_type);


--
-- Name: index_user_profiles_on_style_preference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_profiles_on_style_preference ON public.user_profiles USING btree (style_preference);


--
-- Name: index_user_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_profiles_on_user_id ON public.user_profiles USING btree (user_id);


--
-- Name: index_users_on_admin_true; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_admin_true ON public.users USING btree (admin) WHERE (admin = true);


--
-- Name: index_users_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_at ON public.users USING btree (created_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_jti ON public.users USING btree (jti);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_subscription_tier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_subscription_tier ON public.users USING btree (subscription_tier);


--
-- Name: INDEX index_users_on_subscription_tier; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.index_users_on_subscription_tier IS 'Improves admin analytics queries';


--
-- Name: index_users_on_tier_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_tier_and_created_at ON public.users USING btree (subscription_tier, created_at);


--
-- Name: index_wardrobe_items_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wardrobe_items_on_category ON public.wardrobe_items USING btree (category);


--
-- Name: INDEX index_wardrobe_items_on_category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.index_wardrobe_items_on_category IS 'Improves performance for category filtering';


--
-- Name: index_wardrobe_items_on_color; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wardrobe_items_on_color ON public.wardrobe_items USING btree (color);


--
-- Name: INDEX index_wardrobe_items_on_color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.index_wardrobe_items_on_color IS 'Improves performance for color filtering';


--
-- Name: index_wardrobe_items_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wardrobe_items_on_created_at ON public.wardrobe_items USING btree (created_at);


--
-- Name: index_wardrobe_items_on_embedding; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wardrobe_items_on_embedding ON public.wardrobe_items USING hnsw (embedding public.vector_l2_ops);


--
-- Name: index_wardrobe_items_on_user_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wardrobe_items_on_user_and_created_at ON public.wardrobe_items USING btree (user_id, created_at);


--
-- Name: index_wardrobe_items_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wardrobe_items_on_user_id ON public.wardrobe_items USING btree (user_id);


--
-- Name: outfits fk_rails_0f2ad7c34d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfits
    ADD CONSTRAINT fk_rails_0f2ad7c34d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: outfit_items fk_rails_59496c2d01; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfit_items
    ADD CONSTRAINT fk_rails_59496c2d01 FOREIGN KEY (outfit_id) REFERENCES public.outfits(id);


--
-- Name: outfit_items fk_rails_7635961dd7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfit_items
    ADD CONSTRAINT fk_rails_7635961dd7 FOREIGN KEY (wardrobe_item_id) REFERENCES public.wardrobe_items(id);


--
-- Name: user_profiles fk_rails_87a6352e58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT fk_rails_87a6352e58 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: subscriptions fk_rails_933bdff476; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT fk_rails_933bdff476 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: ad_impressions fk_rails_a3a15a6ee6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_impressions
    ADD CONSTRAINT fk_rails_a3a15a6ee6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: outfit_suggestions fk_rails_b87124b28d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outfit_suggestions
    ADD CONSTRAINT fk_rails_b87124b28d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: wardrobe_items fk_rails_ca2f8b5df5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wardrobe_items
    ADD CONSTRAINT fk_rails_ca2f8b5df5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 9F9eemyHPhIZvy2Po1eEbSVKmoueh1OQDg6phdLClqzRm2yP8OfPRxDYsSHvjtE

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20251211103030'),
('20251208121643'),
('20251207204638'),
('20251205232318'),
('20251205232317'),
('20251204000001'),
('20251201231608'),
('20251201231312'),
('20251201222430'),
('20251201220519'),
('20251128203635'),
('20251128104900'),
('20251128104851');

