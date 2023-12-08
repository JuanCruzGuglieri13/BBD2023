CREATE TABLE usuarios (
	user_id INT PRIMARY KEY,
	name VARCHAR(255),
	lastname VARCHAR(255),
	email VARCHAR(255),
	rol ENUM('cliente', 'empleado')
);
	
CREATE TABLE clientes (
	client_id INT PRIMARY KEY,
	user_id INT,
	cli_password VARCHAR(255),
	cli_birth_date DATE,
	cli_sex ENUM('M', 'F', 'X'),
	cli_user_name VARCHAR(255),
	cli_phone_num INT,
	cli_plan ENUM('basic', 'standard', 'premium'),
	FOREIGN KEY (user_id) REFERENCES usuarios(user_id)
);

CREATE TABLE empleados (
	employee_id INT PRIMARY KEY,
	user_id INT,
	FOREIGN KEY (user_id) REFERENCES usuarios(user_id)
);

CREATE TABLE telefonos (
	phone_id INT PRIMARY KEY,
	employee_id INT,
	phone_number INT,
	FOREIGN KEY (employee_id) REFERENCES empleados(employee_id)
);
	
CREATE TABLE empleado_rol (
	rol_desingado_id INT PRIMARY KEY,
	employee_id INT,
	rol_id INT,
	FOREIGN KEY (employee_id) REFERENCES empleados(employee_id),
	FOREIGN KEY (rol_id) REFERENCES roles(rol_id)
);

CREATE TABLE roles (
	rol_id INT PRIMARY KEY,
	rol VARCHAR(255)
);
	
/*LISTO TABLA USUARIOS*/

CREATE TABLE contenido (
	contenido_id INT PRIMARY KEY,
	title VARCHAR(255),
	description VARCHAR(255),
	type ENUM('pelicula', 'serie_tv')
);

CREATE TABLE acted_by (
	acted_by_id INT PRIMARY KEY,
	contenido_id INT,
	actor_id INT,
	actor_rol ENUM('protagonista', 'secunario')
	FOREIGN KEY (contenido_id) REFERENCES contenido(contenido_id),
	FOREIGN KEY (actor_id) REFERENCES actor(actor_id)
);

CREATE TABLE actor (
	actor_id INT PRIMARY KEY,
	actor_name VARCHAR(255),
	actor_lastname VARCHAR(255)
);

CREATE TABLE directed_by (
	directed_by_id INT PRIMARY KEY,
	contenido_id INT,
	director_id INT,
	FOREIGN KEY (contenido_id) REFERENCES contenido(contenido_id),
	FOREIGN KEY (director_id) REFERENCES director(director_id)
);

CREATE TABLE director (
	director_id INT PRIMARY KEY,
	director_name VARCHAR(255),
	director_lastname VARCHAR(255)
);

CREATE TABLE produced_by (
	produced_by_id INT PRIMARY KEY,
	contenido_id INT,
	producer_id INT,
	FOREIGN KEY (contenido_id) REFERENCES contenido(contenido_id),
	FOREIGN KEY (producer_id) REFERENCES producer(producer_id) 
);

CREATE TABLE producer (
	producer_id INT PRIMARY KEY,
	proucer_name VARCHAR(255)
);

CREATE TABLE genre_contenido (
	genre_cont INT PRIMARY KEY,
	contenido_id INT,
	genre_id INT,
	FOREIGN KEY (contenido_id) REFERENCES contenido(contenido_id),
	FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE TABLE genre (
	genre_id INT PRIMARY KEY,
	genre VARCHAR(255)
);

CREATE TABLE pelicula (
	pelicula_id INT PRIMARY KEY,
	contenido_id INT,
	duration TIME,
	date_since DATE,
	description VARCHAR(255),
	type ENUM('pelicula', 'serie_tv')
);

CREATE TABLE subtitulado_al (
	subtitulado_al INT PRIMARY KEY,
	pelicula_id INT,
	idioma_id INT,
	FOREIGN KEY pelicula_id REFERENCES pelicula(pelicula_id),
	FOREIGN KEY idioma_id REFERENCES idioma(idioma_id)
);

CREATE TABLE idioma (
	idioma_id INT PRIMARY KEY,
	idioma VARCHAR(255)
);

CREATE TABLE serie_tv (

);

	
