## NetFPGA 1G 

### Requisitos

* Projeto Verilog compilado (bitstream)
* Ruby 2.2 ou superior
* OMF EC

### Visão Geral 

Para permitir a reprogramação e controles das máquinas, foram desenvolvidos componentes de softwares baseados em OMF que encapsulam função de baixo nível.  Todas as máquinas possuem um módulo controlador do OMF chamado RC Resource Controller, esse módulo permite operar ações oriundas do ED Experiment Description, e que são comandadas pelo EC Experiment Controller. O OMF permite que o usuário escreva um ED, que por sua vez, é submetido ao EC, que é responsável pelo controle do projeto em nome do usuário. 

O EC emite solicitações no plano de gerenciamento para configurar os recursos conforme especificado no ED. Uma vez que os pré-requisitos da experiência são atendidos, o EC envia diretivas ao RCs associados a cada recurso, os RCs são todos os recursos disponíveis na testbed.


### NetFPGA 1G

O primeiro modelo de placas programáveis criado pela Xilinx foi a NetFPGA 1G, O projeto surgiu em 2006, em parceria com alunos de doutorado da Univerdade de Stanford. Com quatro portas ethernet de 1Gb cada, a placa possui um processador FPGA Xilinx Virtex-II Pro 50 com dois núcleos PowerPC, para processamento dos pacotes, 53.136 elementos lógicos e ciclo de relógio de 8ns (125 MHz). A placa utiliza um barramento PCI ou PCI \textit {Express} para comunicação e programação do FPGA.

A arquitetura FPGA Field-Programmable Gate Array ou arranjo de portas programável, é uma união de memória e processadores de sinais com quatro portas ethernet de 1Gbps. A textit conta com 9 servidores com placas FPGA integradas. Os servidores contém 2 HDDs Hard Drive Disk de 500GB cada, com um mecanismo de tolerância a falhas e automação, que será abordado no capítulo 6, ainda conta com um processador Intel Core 2 Quad 2.66GHz, com 4 núcleos e 8GB de memória RAM DDR3 com 1334 MHz. A documentação oficial do conjunto de drivers e programas da NetFPGA 1G utiliza o sistema operacional Fedora, na versão 13, para sua operação. 

Pelo fato de ser uma distribuição antiga, e já descontinuada, todos os drivers e sofwares foram adaptados para uma distribuição mais recente, do CentOs 7, na arquitetura 64 bits. A portabilidade do conjunto de softwares foi possível visto que ambos os sistemas originam da distribuição Red Hat Linux. 


Os tipos de experimentação possíveis com esse recurso são:
* Gerador de tráfego (utilizando o software iperf).

* Switch de referência - Nesse modo nenhuma configuração posterior é necessária, basta descarregar o arquivo .bit, e a placa já vai comutar os pacotes em L2.

* Roteador de referência - Nesse modo é preciso, além de reprogramar a placa com o binário corresponde, realizar a configuração das ROTAS.

* Roteador de referência OpenFlow - Nesse modo é preciso, além de reprogramar a placa com o binário corresponde, definir o controlador e as regras do OpenFlow.

* Firewall - Nesse modo é preciso, além de reprogramar a placa com o binário correspondente, especificar as regras do firewall através de uma API em C.

* Placa NIC - Após a reprogramação, é preciso configurar IP e máscara de rede nas interfaces desejadas.

Independente do tipo de arquivo especificado para reprogramação, TODOS os RCs tem um método que retorna ao usuário um arquivo de LOG dos registradores das FPGAs, de modo que o usuário possa analisar o comportamento durante e depois do experimento.

O arquivo netfpga1.rb é um exemplo do controlador RC que temos em cada uma das NETFPGAs.

No Arquivo ec.rb  o usuário precisa apenas especificar qual máquina ele quer utilizar, e passar o arquivo .bit como parâmetro. As funções dentro do RC fazendo o encapsulamento dos comandos linux de baixo nível para reprogramação e configuração da placa FPGA.

Após compilar seu projeto usando o servidor de Deploy:

> Copie o arquivo do projeto compilado para o mesmo diretório do arquivo ec.rb, e execute o comando abaixo

```bash
$ omf_ec ec.rb
```
> Após o tempo determinado no controlador, o experimentor retornará ao usuário um arquivo (.txt) com as métricas informados no script EC contendo os dados referente ao experimento.
---


Para mais informações acesse: <br>
[fibre.org.br](https://fibre.org.br/)
