/**
 * Texte de l'application SunuTask
 *
 * Centrenliser les textes permet de:
 *  - Faciliter la traduction (i18n)
 *  - Eviter les fautes de frappe
 *  - Modifier facilement les textes
 */
class AppStrings {
  AppStrings._();

  // ======== Application ==============

  static const String appName = 'SunuTask';
  static const String appSlogan = 'Gérez vos projets efficacement';

 // ============== Onboarding ==============

  static const String onboardingTitle1 = 'Bienvenue sur $appName';
  static const String onboardingDesc1 =
      'Organisez vos projets et taches en toute simplicite. '
      'Une interface intuitive pour une productivite maximale.';

  static const String onboardingTitle2 = 'Collaborez en equipe';
  static const String onboardingDesc2 =
      'Invitez vos collegues, assignez des taches et suivez '
      'l\'avancement de vos projets en temps reel.';

  static const String onboardingTitle3 = 'Restez organise';
  static const String onboardingDesc3 =
      'Definissez des priorites, des deadlines et ne manquez '
      'plus jamais une echeance importante.';

  // ============== Boutons communs ==============

  static const String next = 'Suivant';
  static const String previous = 'Precedent';
  static const String skip = 'Passer';
  static const String done = 'Terminer';
  static const String cancel = 'Annuler';
  static const String confirm = 'Confirmer';
  static const String save = 'Enregistrer';
  static const String delete = 'Supprimer';
  static const String edit = 'Modifier';
  static const String add = 'Ajouter';
  static const String search = 'Rechercher';
  static const String filter = 'Filtrer';
  static const String retry = 'Reessayer';
  static const String getStarted = 'Commencer';

  // ============== Authentification ==============

  static const String login = 'Connexion';
  static const String register = 'Inscription';
  static const String logout = 'Deconnexion';
  static const String email = 'Email';
  static const String password = 'Mot de passe';
  static const String confirmPassword = 'Confirmer le mot de passe';
  static const String name = 'Nom';
  static const String forgotPassword = 'Mot de passe oublie ?';
  static const String noAccount = 'Pas encore de compte ?';
  static const String haveAccount = 'Deja un compte ?';

  // ============== Projets ==============

  static const String projects = 'Projets';
  static const String project = 'Projet';
  static const String newProject = 'Nouveau projet';
  static const String editProject = 'Modifier le projet';
  static const String deleteProject = 'Supprimer le projet';
  static const String projectName = 'Nom du projet';
  static const String projectDescription = 'Description';
  static const String projectColor = 'Couleur';
  static const String noProjects = 'Aucun projet';
  static const String noProjectsDesc = 'Creez votre premier projet pour commencer';

  // ============== Taches ==============

  static const String tasks = 'Taches';
  static const String task = 'Tache';
  static const String newTask = 'Nouvelle tache';
  static const String editTask = 'Modifier la tache';
  static const String deleteTask = 'Supprimer la tache';
  static const String taskTitle = 'Titre';
  static const String taskDescription = 'Description';
  static const String taskStatus = 'Statut';
  static const String taskPriority = 'Priorite';
  static const String taskDueDate = 'Date limite';
  static const String taskAssignee = 'Assigne a';
  static const String noTasks = 'Aucune tache';
  static const String noTasksDesc = 'Ajoutez votre premiere tache';

  // ============== Statuts ==============

  static const String statusTodo = 'A faire';
  static const String statusInProgress = 'En cours';
  static const String statusDone = 'Termine';

  // ============== Priorites ==============

  static const String priorityLow = 'Basse';
  static const String priorityMedium = 'Moyenne';
  static const String priorityHigh = 'Haute';

  // ============== Navigation ==============

  static const String home = 'Accueil';
  static const String settings = 'Parametres';
  static const String profile = 'Profil';

  // ============== Messages ==============

  static const String loading = 'Chargement...';
  static const String error = 'Une erreur est survenue';
  static const String errorOccurred = 'Une erreur est survenue';
  static const String success = 'Operation reussie';
  static const String confirmDelete = 'Etes-vous sur de vouloir supprimer ?';

  // ============== Validation ==============

  static const String requiredField = 'Ce champ est requis';
  static const String nameRequired = 'Le nom est requis';
  static const String emailRequired = 'L\'email est requis';
  static const String passwordRequired = 'Le mot de passe est requis';
  static const String invalidEmail = 'Email invalide';
  static const String emailInvalid = 'Email invalide';
  static const String passwordTooShort = 'Le mot de passe doit contenir au moins 6 caracteres';
  static const String passwordsNotMatch = 'Les mots de passe ne correspondent pas';

  // ============== Alias pour compatibilite ==============

  static const String hasAccount = haveAccount;
}