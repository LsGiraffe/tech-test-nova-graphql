# Architecture

## Mes décisions

- Les pièces portent des dates métier explicites. created_at et updated_at ne suffisent pas pour mesurer l’attente: l’ajout d’une note interne modifie par exemple updated_at sans changement de statut.
Chaque pièce a donc une date qui correspond à l'action precedente, et qui corrèle la prochaine action attendue:
     - Pièce requise soit automatique soit par l'expert, à fournir par le client: requested_at.
     - Fournie par le client, à contrôler par l'expert: submitted_at.
     - Refusée par l'expert, à re-fournir par le client: rejected_at.
     - Validée par l'expert: aucune attente, approved_at date la validation.
Ces dates permettent de déterminer les dossiers bloqués selon la règle définie dans les hypothèses, et de dater les événements métier de progression de chaque pièce
Une migration ajoute les dates métier et les instructions nécessaires à la query client, les tables et statuts existants sont conservés.

- Une pièce attendue = une unité de contrôle. Trois bulletins de salaire correspondent à trois pièces, avec l'emprunteur et la période précisés dans les instructions. Chacune possède son statut et ses dates, afin de permettre une validation et un remplacement indépendants. Un seul fichier est accepté par pièce, si le justificatif comporte plusieurs pages, elles doivent être regroupées dans ce fichier.

- Côté expert, la liste de dossiers affichée est triée avec priorisation des dossiers en attente du traitement d'une pièce. Les dossiers avec des pièces à contrôler apparaissent en premier, selon l’ancienneté du document en attente le plus ancien. Ca évite qu’un ancien dossier nécessitant une action soit masqué par des dossiers récents. Le filtre de blocage permet aussi à l'expert d’identifier rapidement les dossiers en attente. La pagination utilise limit / offset pour sa simplicité.

- Le processus d'upload de doc par l'utilisateurpasse d’abord par un transfert du fichier vers un stockage objet (type S3). La mutation submitDocument reçoit ensuite sa référence (fileId) et l’identifiant de la pièce attendue (documentId). Le serveur vérifie que l’appelant peut utiliser ce fichier et accéder à cette pièce avant de les associer.

- On garde un type Document commun entre Client et Expert, même si le type contient un champ note qui ne peut et doit être vu que par l'expert. Pour éviter de dupliquer le type. Par contre ça requiert une vérification forte dans le code métier.

## Les trous du brief

| Question | Hypothèse |
| --- | --- |
| Est-ce que le dossier doit atteindre un niveau de complétude mini, ou contenir certaines pièces 'obligatoires' pour qu'un expert commence le traitement ? | On considère que l'expert peut commencer à traiter les documents sans minimum requis. Le brief mentionne qu'il est important que le client sache où il en est et qu'il aille au bout du process: cela permet des retours progressifs et des corrections plus tôt, avec l’objectif de faciliter la poursuite du parcours client et inciter le client à aller au bout. |
| C'est quoi un dossier qui 'bloque'. Plusieurs possibilités: dossier créé depuis X temps et pas terminé, dossier qui contient des pièces refusées ... | Un dossier est considéré comme bloqué lorsqu’au moins une pièce attend une action du client ou de l’expert depuis plus qu’un seuil choisi arbitrairement (on va prendre 72 heures pour l'exercice). L’attente est mesurée depuis la demande initiale, le dépot ou le refus, et se base sur le système de dates métier mentionné dans les décisions archi. |
| Est-ce qu'il faut garder un historique des pièces refusées ou elles sont écrasées lorsque le client fourni la pièce en remplacement | Lors du remplacement d’une pièce refusée, seul le nouveau dépôt est conservé, il override l'ancien. |
| Règles d'accès aux dossiers | L’appelant client est rattaché à un seul dossier et peut consulter et déposer les pièces des deux co-emprunteurs |

## Ce que j'ai laissé de côté

- La gestion de comptes distincts et de permissions individuelles entre co-emprunteurs. Et même du concept d'identité distinctes entre co-emprunteurs.
- L’historique des dépôts et contrôles précédents, afin de limiter la complexité du modèle
- La génération des pièces demandées en fonction du contexte de la demande du client est supposée réalisée en amont
- Le processus d'upload de fichier dans S3 préalable à la mutation submitDocument
- L'identité de l'expert et son assignation aux dossiers: le modèle actuel n'a ni table advisors ni advisor_id sur mortgage_project (seulement un advisor_name en texte), et le Viewer simulé ne porte qu'un project_id unique, comme le client. expertProjects/expertProject sont proposés au niveau du schéma, mais l'assignation réelle dossier <=> expert reste à modéliser.
