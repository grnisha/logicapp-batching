# Batching example

This is a sample implementation of message batching in logic apps standard. In this example there are two logic app workflows - a batch sender and a batch receiver.

The batch sender receives messages from storage queue in xml format, logs some details to application insights and invokes batch receiver.

The batch receiver workkflow is configured to batch all messages based on time interval, in this case 1 hour. This workflow validates all messages in the batch based on a field in the message. All valid messages in the bacth are then converted into json & uploaded to a blob. It also sends a summary email report with success & failure counts. 

