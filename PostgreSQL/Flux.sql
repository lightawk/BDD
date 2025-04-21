-- Creation la base de donnees
CREATE DATABASE FLUX;

-- Creation du schema
CREATE SCHEMA RAPPORT;

-- Visualiser
set search_path=rapport;
\d nom_table

/* **************************
 * TABLE 0 : SITES LOGIQUES * 
 * **************************/

-- Creation de la table pour les sites logiques
CREATE TABLE rapport.site_logique (
	site_logique_id VARCHAR(10) NOT NULL,
	PRIMARY KEY (site_logique_id)
);

-- Insertion des valeurs
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL1V');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL2V');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL3V');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL4V');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL5V');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL7V');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL1M');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL2M');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL3M');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL4M');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL5M');
INSERT INTO rapport.site_logique(site_logique_id) VALUES('SL7M');

-- Suppression de la table pour les sites logiques
DROP TABLE rapport.site_logique;

/* TABLES POUR LES RAPPORTS */

/* *********************
 * TABLE 1 : RECV_SEND * 
 * *********************/

-- Creation de la table pour le rapport [ recv_send ]
CREATE TABLE rapport.recv_send (
	site_logique_id VARCHAR(10) NOT NULL,
	snapshot        TIMESTAMP   NOT NULL,
	recv            INTEGER     NOT NULL,
	send            INTEGER     NOT NULL,
	passtrans       INTEGER     NOT NULL,
	PRIMARY KEY (site_logique_id, snapshot),
	FOREIGN KEY (site_logique_id) REFERENCES rapport.site_logique (site_logique_id) 
);

-- Insertion des valeurs (=valeurs de test)
INSERT INTO rapport.recv_send(site_logique_id, snapshot, recv, send, passtrans) VALUES('SL1V', NOW(), 0, 0, 0);
INSERT INTO rapport.recv_send(site_logique_id, snapshot, recv, send, passtrans) VALUES('SL1V', NOW(), 2, 0, 0);
INSERT INTO rapport.recv_send(site_logique_id, snapshot, recv, send, passtrans) VALUES('SL2V', NOW(), 0, 1, 0);
INSERT INTO rapport.recv_send(site_logique_id, snapshot, recv, send, passtrans) VALUES('SL2V', NOW(), 0, 1, 2);

-- Suppression de la table pour le rapport [ recv_send ]
DROP TABLE rapport.recv_send;