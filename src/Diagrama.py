from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECS, EKS, Lambda
from diagrams.aws.database import RDS
from diagrams.aws.integration import SQS
from diagrams.aws.storage import S3
from diagrams.aws.general import User

with Diagram("Processo de Venda de Bombons", show=False):
    cliente = User("Cliente")

    with Cluster("Processamento de Pedido"):
        with Cluster("Front-End"):
            app_web = EKS("Aplicativo Web")

        with Cluster("Serviço de Pedido"):
            servico_pedido = ECS("Serviço de Pedido")

        with Cluster("Fila de Pedidos"):
            fila_pedidos = SQS("Fila de Pedidos")

        with Cluster("Processamento"):
            processadores_pedido = [Lambda("validadar e registrar o pedido"),
                                    Lambda("processo de pagamentos e confirmações do pedido")]

        with Cluster("Armazenamento"):
            estoque_bombons = S3("Estoque de Bombons")  
            historico_pedidos = RDS("Histórico de Pedidos")  
            dados_analiticos = S3("Dados estatísticos")  #armazena os dados sobre venda, desempenho do sistema, para ajudar na geração de ralatorio

    cliente >> app_web >> servico_pedido >> fila_pedidos >> processadores_pedido
    processadores_pedido >> historico_pedidos
    processadores_pedido >> estoque_bombons
    processadores_pedido >> dados_analiticos
    historico_pedidos >> dados_analiticos