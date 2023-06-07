terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_key_pair" "key" {                      #Vincula a chave com a AWS (cria um par de chaves)
  key_name   = "aws-key"
  public_key = file("./aws-key.pub")
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias = "us-east-2"
  region = "us-east-2"
}

resource "aws_instance" "dev" {
  count         = 3                              # Quantidade de máquinas;
  ami           = "ami-053b0d53c279acc90"        # Imagem da instancia;
  instance_type = "t2.micro"                     # Tipo de instancia;
  key_name      = aws_key_pair.key.key_name      # Chave key que esta no diretório corrente;
  tags = {
    Name = "dev.${count.index}"                   # Nome das instancias iniciará com Dev e terminará com o indice da instancia;
  }
  vpc_security_group_ids = [aws_security_group.acesso-ssh.id]
}

resource "aws_instance" "dev4" {
  provider      = aws.us-east-2
  ami           = "ami-024e6efaf93d85776"        # Imagem da instancia;
  instance_type = "t2.micro"                     # Tipo de instancia;
  key_name      = aws_key_pair.key.key_name      # Chave key que esta no diretório corrente;
  tags = {
    Name = "dev.4"                               # Nome das instancias iniciará com Dev e terminará com o indice da instancia;
  }
  vpc_security_group_ids = [aws_security_group.acesso-ssh-us-east-2.id]
  depends_on = [ aws_dynamodb_table.dynamodb-homologacao ]        # Depende do Dynamondb;
}



resource "aws_dynamodb_table" "dynamodb-homologacao" {
  provider       = aws.us-east-2
  name           = "GameScores"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "UserId"
  range_key      = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }
}