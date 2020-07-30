# AMQP: 5671
# MQTT: 8883
# OpenWire: 61617
# STOMP: 61614
# WebSocket: 61619

resource "aws_mq_configuration" "custom_mq_conf_1" {
  name           = "custom_mq_conf_1"
  description    = "Custom Amazon MQ Configuration"
  engine_type    = "ActiveMQ"
  engine_version = "5.15.0"

  data = <<DATA
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<broker xmlns="http://activemq.apache.org/schema/core">
  <plugins>
    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
    <statisticsBrokerPlugin/>
    <timeStampingBrokerPlugin ttlCeiling="86400000" zeroExpirationOverride="86400000"/>
  </plugins>
</broker>
DATA
}

resource "aws_mq_broker" "custom_mq_broker_1" {
  broker_name        = "custom_mq_broker_1"
  engine_type        = "ActiveMQ"
  engine_version     = "5.15.12"
  host_instance_type = "mq.t2.micro"
  security_groups    = [aws_security_group.custom_public_sg_1.id]

  configuration {
    id       = aws_mq_configuration.custom_mq_conf_1.id
    revision = aws_mq_configuration.custom_mq_conf_1.latest_revision
  }

  subnet_ids = [aws_subnet.custom_public_subnet_1.id]

  apply_immediately          = true
  auto_minor_version_upgrade = true
  # SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ
  deployment_mode     = "SINGLE_INSTANCE"
  publicly_accessible = true

  encryption_options {
    use_aws_owned_key = false
    kms_key_id        = var.kms_key_id
  }

  logs {
    general = true
    audit   = true
  }

  user {
    username       = "user1"
    password       = "myPassword123"
    console_access = true
  }

}
