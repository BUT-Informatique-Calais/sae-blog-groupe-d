<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20250422143210 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE TABLE article (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          categorie_id INTEGER DEFAULT NULL,
          title VARCHAR(255) NOT NULL,
          content CLOB NOT NULL,
          published_at DATETIME NOT NULL --(DC2Type:datetime_immutable)
          ,
          image_name VARCHAR(255) DEFAULT NULL,
          updated_at DATETIME DEFAULT NULL --(DC2Type:datetime_immutable)
          ,
          CONSTRAINT FK_23A0E66BCF5E72D FOREIGN KEY (categorie_id) REFERENCES categorie (id) NOT DEFERRABLE INITIALLY IMMEDIATE
        )');
        $this->addSql('CREATE INDEX IDX_23A0E66BCF5E72D ON article (categorie_id)');
        $this->addSql('CREATE TABLE categorie (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          label VARCHAR(100) NOT NULL
        )');
        $this->addSql('CREATE TABLE user (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          email VARCHAR(180) NOT NULL,
          roles CLOB NOT NULL --(DC2Type:json)
          ,
          PASSWORD VARCHAR(255) NOT NULL
        )');
        $this->addSql('CREATE UNIQUE INDEX UNIQ_8D93D649E7927C74 ON user (email)');
        $this->addSql('CREATE TABLE messenger_messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          body CLOB NOT NULL,
          headers CLOB NOT NULL,
          queue_name VARCHAR(190) NOT NULL,
          created_at DATETIME NOT NULL --(DC2Type:datetime_immutable)
          ,
          available_at DATETIME NOT NULL --(DC2Type:datetime_immutable)
          ,
          delivered_at DATETIME DEFAULT NULL --(DC2Type:datetime_immutable)
          )');
        $this->addSql('CREATE INDEX IDX_75EA56E0FB7336F0 ON messenger_messages (queue_name)');
        $this->addSql('CREATE INDEX IDX_75EA56E0E3BD61CE ON messenger_messages (available_at)');
        $this->addSql('CREATE INDEX IDX_75EA56E016BA31DB ON messenger_messages (delivered_at)');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('DROP TABLE article');
        $this->addSql('DROP TABLE categorie');
        $this->addSql('DROP TABLE user');
        $this->addSql('DROP TABLE messenger_messages');
    }
}
