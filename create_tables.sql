DROP SCHEMA IF EXISTS music_festival CASCADE;
CREATE SCHEMA music_festival;

CREATE TABLE music_festival.genre (
    genre_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT uq_genre_name UNIQUE (name)
);
CREATE TABLE music_festival.artist (
    artist_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(100) NOT NULL,
    fee NUMERIC(12,2) NOT NULL,
    CONSTRAINT chk_artist_fee CHECK (fee >= 0)
);
CREATE TABLE music_festival.artist_genre (
    artist_id INT NOT NULL,
    genre_id INT NOT NULL,
    CONSTRAINT pk_artist_genre PRIMARY KEY (artist_id, genre_id),
    CONSTRAINT fk_artist_genre_artist
        FOREIGN KEY (artist_id)
        REFERENCES music_festival.artist (artist_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_artist_genre_genre
        FOREIGN KEY (genre_id)
        REFERENCES music_festival.genre (genre_id)
        ON DELETE CASCADE
);
CREATE TABLE music_festival.stage (
    stage_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    location VARCHAR(255) NOT NULL,
    CONSTRAINT chk_cap CHECK (capacity > 0),
    CONSTRAINT uq_stage_name UNIQUE (name)
);
CREATE TABLE music_festival.performance (
    performance_id INT PRIMARY KEY,
    artist_id INT NOT NULL,
    stage_id INT NOT NULL, 
    start_dttm TIMESTAMP NOT NULL,
    end_dttm TIMESTAMP NOT NULL,
    fee NUMERIC(12,2) NOT NULL,
    CONSTRAINT fk_performance_artist
        FOREIGN KEY (artist_id)
        REFERENCES music_festival.artist (artist_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_performance_stage
        FOREIGN KEY (stage_id)
        REFERENCES music_festival.stage (stage_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_performance_end_dttm CHECK (end_dttm > start_dttm),
    CONSTRAINT chk_performance_fee CHECK (fee >= 0)
);
CREATE TABLE music_festival.employee (
    employee_id INT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    position VARCHAR(100) NOT NULL,
    phone VARCHAR(16) NOT NULL,
    hire_date DATE NOT NULL,
    CONSTRAINT uq_employee_phone UNIQUE (phone),
    CONSTRAINT chk_employee_phone CHECK (phone ~ '^\+[0-9]{11,15}$')
);
CREATE TABLE music_festival.contractor (
    contractor_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    service_type VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(16) NOT NULL,
    CONSTRAINT uq_contractor_name UNIQUE (name),
    CONSTRAINT chk_contractor_phone CHECK (contact_phone ~ '^\+[0-9]{11,15}$')
);
CREATE TABLE music_festival.sponsor (
    sponsor_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(16) NOT NULL,
    CONSTRAINT uq_sponsor_name UNIQUE (name),
    CONSTRAINT chk_sponsor_email CHECK (contact_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_sponsor_phone CHECK (contact_phone ~ '^\+[0-9]{11,15}$')
);

CREATE TABLE music_festival.equipment (
    equipment_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    contractor_id INT,
    stage_id INT,
    CONSTRAINT fk_equipment_contractor
        FOREIGN KEY (contractor_id)
        REFERENCES music_festival.contractor (contractor_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_equipment_stage
        FOREIGN KEY (stage_id)
        REFERENCES music_festival.stage (stage_id)
        ON DELETE SET NULL
);
CREATE TABLE music_festival.shift (
    shift_id INT PRIMARY KEY,
    stage_id INT NOT NULL,
    start_dttm TIMESTAMP NOT NULL,
    end_dttm TIMESTAMP NOT NULL,
    CONSTRAINT fk_shift_stage
        FOREIGN KEY (stage_id)
        REFERENCES music_festival.stage (stage_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_shift_time CHECK (end_dttm > start_dttm)
);
CREATE TABLE music_festival.sponsorship (
    sponsorship_id INT PRIMARY KEY,
    sponsor_id INT NOT NULL,
    performance_id INT,
    amount NUMERIC(14,2) NOT NULL,
    contract_dttm TIMESTAMP NOT NULL,
    terms TEXT,
    CONSTRAINT fk_sponsorship_sponsor
        FOREIGN KEY (sponsor_id)
        REFERENCES music_festival.sponsor (sponsor_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_sponsorship_performance
        FOREIGN KEY (performance_id)
        REFERENCES music_festival.performance (performance_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_sponsorship_amount CHECK (amount > 0)
);
CREATE TABLE music_festival.contract_version (
    contract_version_id INT PRIMARY KEY,
    sponsorship_id INT NOT NULL,
    terms TEXT NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE,
    CONSTRAINT fk_contract_version_sponsorship
        FOREIGN KEY (sponsorship_id)
        REFERENCES music_festival.sponsorship (sponsorship_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_contract_version_date UNIQUE (sponsorship_id, valid_from),
    CONSTRAINT chk_contract_version_amount CHECK (amount > 0),
    CONSTRAINT chk_contract_version_valid CHECK (valid_to IS NULL OR valid_to > valid_from)
);
CREATE TABLE music_festival.ticket_category (
    category_id INT PRIMARY KEY,
    performance_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    base_price NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_ticket_category_performance
        FOREIGN KEY (performance_id)
        REFERENCES music_festival.performance (performance_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_ticket_category_name UNIQUE (performance_id, name),
    CONSTRAINT chk_ticket_category_price CHECK (base_price >= 0)
);
CREATE TABLE music_festival.price_history (
    price_id INT PRIMARY KEY,
    category_id INT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE,
    CONSTRAINT fk_price_history_category
        FOREIGN KEY (category_id)
        REFERENCES music_festival.ticket_category (category_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_price_history_date UNIQUE (category_id, valid_from),
    CONSTRAINT chk_price_history_price CHECK (price >= 0),
    CONSTRAINT chk_price_history_valid CHECK (valid_to IS NULL OR valid_to > valid_from)
);
CREATE TABLE music_festival.ticket (
    ticket_id INT PRIMARY KEY,
    category_id INT NOT NULL,
    price_id INT NOT NULL,
    seat_number VARCHAR(20),
    sold_dttm TIMESTAMP,
    status VARCHAR(15) NOT NULL,
    CONSTRAINT fk_ticket_category
        FOREIGN KEY (category_id)
        REFERENCES music_festival.ticket_category (category_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_ticket_price
        FOREIGN KEY (price_id)
        REFERENCES music_festival.price_history (price_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_ticket_status CHECK (status IN ('available', 'sold', 'returned'))
);
CREATE TABLE music_festival.employee_shift (
    shift_id INT NOT NULL,
    employee_id INT NOT NULL,
    role VARCHAR(100) NOT NULL,
    CONSTRAINT pk_employee_shift PRIMARY KEY (shift_id, employee_id),
    CONSTRAINT fk_employee_shift_shift
        FOREIGN KEY (shift_id)
        REFERENCES music_festival.shift (shift_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_employee_shift_employee
        FOREIGN KEY (employee_id)
        REFERENCES music_festival.employee (employee_id)
        ON DELETE CASCADE
);