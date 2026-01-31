// ===================================
//   ALIDOR JavaScript - Complete Script
// ===================================

// Global Variables
let currentLanguage = 'ar';
let currentTheme = 'light';
let currentProduct = null;
let currentImageIndex = 0;

// Product Data
const products = {
    'royal-comfort': {
        id: 'royal-comfort',
        name: {
            ar: 'Royal Comfort',
            fr: 'Royal Comfort'
        },
        description: {
            ar: 'مرتبة فاخرة مصنوعة من أجود المواد للحصول على أقصى درجات الراحة والاستجمام',
            fr: 'Matelas de luxe fabriqué avec les meilleurs matériaux pour un maximum de confort et de détente'
        },
        price: '3500',
        images: [
            'images/royal_comfort_1.jpg',
            'images/royal_comfort_2.jpeg',
            'images/royal_comfort_3.jpg'
        ]
    },
    'ortho-plus': {
        id: 'ortho-plus',
        name: {
            ar: 'Ortho Plus',
            fr: 'Ortho Plus'
        },
        description: {
            ar: 'مرتبة طبية متخصصة في دعم العمود الفقري وتخفيف آلام الظهر مع الحفاظ على الراحة',
            fr: 'Matelas médical spécialisé dans le soutien de la colonne vertébrale et le soulagement des douleurs dorsales'
        },
        price: '2800',
        images: [
            'images/ortho_plus_1.jpg',
            'images/ortho_plus_2.jpg',
            'images/ortho_plus_3.jpg'
        ]
    },
    'memory-dream': {
        id: 'memory-dream',
        name: {
            ar: 'Memory Dream',
            fr: 'Memory Dream'
        },
        description: {
            ar: 'مرتبة فوم الذاكرة التي تتكيف مع شكل الجسم لتوفير الدعم الأمثل والنوم الهادئ',
            fr: 'Matelas en mousse à mémoire qui s\'adapte à la forme du corps pour un soutien optimal et un sommeil paisible'
        },
        price: '2500',
        images: [
            'images/memory_dream_1.jpg',
            'images/memory_dream_2.jpg',
            'images/memory_dream_3.webp'
        ]
    },
    'classic-spring': {
        id: 'classic-spring',
        name: {
            ar: 'Classic Spring',
            fr: 'Classic Spring'
        },
        description: {
            ar: 'مرتبة زنبركية تقليدية عالية الجودة توفر الدعم المثالي والتهوية الممتازة',
            fr: 'Matelas à ressorts traditionnel de haute qualité offrant un soutien optimal et une excellente ventilation'
        },
        price: '2200',
        images: [
            'images/classic_spring_1.jpeg',
            'images/classic_spring_2.jpg',
            'images/classic_spring_3.jpg'
        ]
    }
};

// Translation Data
const translations = {
    ar: {
        // Navigation
        'nav.home': 'الرئيسية',
        'nav.products': 'المنتجات',
        'nav.about': 'عن الشركة',
        'nav.contact': 'التواصل',

        // Hero Section
        'hero.title': 'راحة نومك تبدأ من ALIDOR',
        'hero.subtitle': 'نُصمم المراتب حسب المقاسات التي تحتاجها… الجودة والراحة في مرتبة واحدة',
        'hero.cta': 'اطلب الآن',
        'hero.explore': 'استكشف المنتجات',

        // Features
        'feature.quality': 'جودة عالية',
        'feature.quality.desc': 'مواد فاخرة',
        'feature.warranty': 'ضمان 5 سنوات',
        'feature.warranty.desc': 'ثقة وأمان',
        'feature.delivery': 'توصيل مجاني',
        'feature.delivery.desc': 'لجميع المدن',
        'feature.luxury': 'مواد فاخرة',
        'feature.comfort': 'راحة استثنائية',
        'feature.medical': 'دعم طبي',
        'feature.spine': 'للعمود الفقري',
        'feature.memory': 'فوم الذاكرة',
        'feature.adapt': 'تكيف مع الجسم',
        'feature.spring': 'زنبرك كلاسيكي',
        'feature.durable': 'متانة عالية',

        // Products
        'products.title': 'مجموعة مراتب ALIDOR',
        'products.subtitle': 'اختر مرتبتك المثالية من مجموعتنا المتنوعة',
        'products.royal.title': 'Royal Comfort',
        'products.royal.description': 'مرتبة فاخرة مصنوعة من أجود المواد',
        'products.ortho.title': 'Ortho Plus',
        'products.ortho.description': 'مرتبة طبية لدعم العمود الفقري',
        'products.memory.title': 'Memory Dream',
        'products.memory.description': 'مرتبة فوم ذاكرة للراحة المثلى',
        'products.spring.title': 'Classic Spring',
        'products.spring.description': 'مرتبة زنبركية تقليدية مريحة',
        'products.order': 'اطلب الآن',
        'products.from': 'ابتداءً من',
        'products.dh': 'درهم',
        'badge.bestseller': 'الأكثر مبيعاً',

        // Custom Order
        'custom.title': 'مقاسات خاصة؟ تصميم مخصص؟',
        'custom.subtitle': 'نحن نصنع المراتب حسب احتياجاتك الخاصة',
        'custom.cta': 'اطلب استشارة مجانية',

        // About
        'about.title': 'عن شركة ALIDOR',
        'about.description': 'شركة ALIDOR هي رائدة في صناعة المراتب الفاخرة في المغرب. نحن ملتزمون بتوفير أفضل تجربة نوم ممكنة من خلال منتجاتنا عالية الجودة.',
        'about.quality': 'جودة عالية',
        'about.quality.desc': 'نستخدم أفضل المواد والتقنيات',
        'about.comfort': 'راحة مطلقة',
        'about.comfort.desc': 'تصميم يضمن النوم المريح',
        'about.custom': 'مقاسات مخصصة',
        'about.custom.desc': 'نصنع حسب احتياجاتك',

        // Story
        'story.title': 'قصتنا',
        'story.p1': 'بدأت رحلة ALIDOR منذ أكثر من 15 عاماً برؤية واضحة: توفير مراتب عالية الجودة تضمن نوماً مريحاً وصحياً للجميع.',
        'story.p2': 'نحن نؤمن بأن النوم الجيد هو أساس الحياة الصحية، لذلك نستخدم أفضل المواد والتقنيات الحديثة في صناعة مراتبنا.',
        'story.p3': 'اليوم، نفخر بكوننا من الرواد في صناعة المراتب في المغرب، ونستمر في الابتكار لتقديم الأفضل لعملائنا.',
        'vision.title': 'رؤيتنا',
        'vision.text': 'أن نكون الخيار الأول للمراتب الفاخرة في المغرب',
        'mission.title': 'مهمتنا',
        'mission.text': 'تحسين جودة النوم لكل عائلة مغربية',

        // Statistics
        'stat.customers': 'عميل راضٍ',
        'stat.experience': 'سنة خبرة',
        'stat.cities': 'مدينة نخدمها',
        'stat.satisfaction': 'رضا العملاء',

        // Contact
        'contact.title': 'تواصل معنا',
        'contact.subtitle': 'نحن هنا لمساعدتك في اختيار المرتبة المثالية',
        'contact.info.title': 'معلومات التواصل',
        'contact.phone': 'الهاتف',
        'contact.whatsapp': 'واتساب',
        'contact.address': 'العنوان',
        'contact.address.value': 'الدار البيضاء، المغرب',
        'contact.hours': 'ساعات العمل',
        'contact.hours.value': 'الإثنين - السبت: 9:00 - 19:00',

        // Map
        'map.title': 'موقعنا',
        'map.placeholder': 'خريطة تفاعلية قريباً',

        // Contact Form
        'form.title': 'أرسل لنا رسالة',
        'form.name': 'الاسم الكامل',
        'form.name.placeholder': 'أدخل اسمك الكامل',
        'form.phone': 'رقم الهاتف',
        'form.phone.placeholder': '+212 6XX XXX XXX',
        'form.email': 'البريد الإلكتروني',
        'form.email.placeholder': 'example@email.com',
        'form.subject': 'موضوع الرسالة',
        'form.subject.placeholder': 'اختر موضوع الرسالة',
        'form.subject.order': 'طلب مرتبة',
        'form.subject.custom': 'مقاس مخصص',
        'form.subject.support': 'دعم فني',
        'form.subject.other': 'أخرى',
        'form.message': 'الرسالة',
        'form.message.placeholder': 'اكتب رسالتك هنا...',
        'form.submit': 'إرسال الرسالة',

        // Quick Actions
        'quick.title': 'تحتاج إجابة سريعة؟',
        'quick.subtitle': 'تواصل معنا مباشرة عبر واتساب للحصول على رد فوري',
        'quick.cta': 'تحدث معنا الآن',

        // Footer
        'footer.description': 'شركة رائدة في صناعة المراتب الفاخرة في المغرب. نحن ملتزمون بتوفير أفضل تجربة نوم ممكنة.',
        'footer.address': 'الدار البيضاء، المغرب',
        'footer.links.title': 'روابط سريعة',
        'footer.products.title': 'منتجاتنا',
        'footer.newsletter.title': 'تابعنا',
        'footer.newsletter.desc': 'اشترك في نشرتنا البريدية للحصول على أحدث العروض',
        'footer.newsletter.placeholder': 'بريدك الإلكتروني',
        'footer.newsletter.submit': 'اشترك',
        'footer.social.title': 'تابعنا على وسائل التواصل الاجتماعي',
        'footer.year': '2025',
        'footer.rights': 'جميع الحقوق محفوظة لشركة ALIDOR',
        'footer.privacy': 'سياسة الخصوصية',
        'footer.terms': 'شروط الاستخدام',
        'footer.made': 'صُنع بـ',
        'footer.morocco': 'في المغرب',

        // Modal
        'modal.title': 'اطلب مرتبتك الآن',
        'modal.name': 'الاسم الكامل',
        'modal.name.placeholder': 'أدخل اسمك الكامل',
        'modal.city': 'المدينة',
        'modal.city.placeholder': 'الدار البيضاء، الرباط، إلخ...',
        'modal.phone': 'رقم الهاتف',
        'modal.phone.placeholder': '+212 6XX XXX XXX',
        'modal.size': 'المقاس',
        'modal.size.placeholder': 'اختر المقاس',
        'modal.size.single': '90×190 سم (سرير مفرد)',
        'modal.size.single_large': '120×190 سم (سرير مفرد كبير)',
        'modal.size.double_small': '140×190 سم (سرير مزدوج صغير)',
        'modal.size.double': '160×200 سم (سرير مزدوج)',
        'modal.size.queen': '180×200 سم (سرير كوين)',
        'modal.size.king': '200×200 سم (سرير كينغ)',
        'modal.size.custom': 'مقاس مخصص',
        'modal.custom_size': 'المقاس المخصص',
        'modal.custom_size.placeholder': 'مثال: 150×200 سم',
        'modal.cancel': 'إلغاء',
        'modal.submit': 'إرسال عبر واتساب',

        // Validation
        'validation.name': 'يرجى إدخال الاسم',
        'validation.city': 'يرجى إدخال المدينة',
        'validation.phone': 'يرجى إدخال رقم هاتف صحيح',
        'validation.size': 'يرجى اختيار المقاس',
        'validation.custom_size': 'يرجى إدخال المقاس المخصص',

        // WhatsApp
        'whatsapp.tooltip.title': 'تحدث معنا الآن',
        'whatsapp.tooltip.text': 'نحن متاحون للإجابة على أسئلتك ومساعدتك في اختيار المرتبة المثالية',
        'whatsapp.tooltip.cta': 'ابدأ المحادثة',
        'whatsapp.mobile.cta': 'تواصل معنا عبر واتساب',
        'whatsapp.message': 'مرحباً، أود الاستفسار عن مراتب ALIDOR'
    },
    fr: {
        // Navigation
        'nav.home': 'Accueil',
        'nav.products': 'Produits',
        'nav.about': 'À propos',
        'nav.contact': 'Contact',

        // Hero Section
        'hero.title': 'Votre confort de sommeil commence avec ALIDOR',
        'hero.subtitle': 'Nous concevons des matelas selon les dimensions dont vous avez besoin... Qualité et confort en un seul matelas',
        'hero.cta': 'Commander maintenant',
        'hero.explore': 'Découvrir les produits',

        // Features
        'feature.quality': 'Haute qualité',
        'feature.quality.desc': 'Matériaux luxueux',
        'feature.warranty': 'Garantie 5 ans',
        'feature.warranty.desc': 'Confiance et sécurité',
        'feature.delivery': 'Livraison gratuite',
        'feature.delivery.desc': 'Dans toutes les villes',
        'feature.luxury': 'Matériaux luxueux',
        'feature.comfort': 'Confort exceptionnel',
        'feature.medical': 'Support médical',
        'feature.spine': 'Pour la colonne',
        'feature.memory': 'Mousse mémoire',
        'feature.adapt': 'S\'adapte au corps',
        'feature.spring': 'Ressort classique',
        'feature.durable': 'Haute durabilité',

        // Products
        'products.title': 'Collection de matelas ALIDOR',
        'products.subtitle': 'Choisissez votre matelas idéal parmi notre gamme variée',
        'products.royal.title': 'Royal Comfort',
        'products.royal.description': 'Matelas de luxe fabriqué avec les meilleurs matériaux',
        'products.ortho.title': 'Ortho Plus',
        'products.ortho.description': 'Matelas médical pour le soutien de la colonne vertébrale',
        'products.memory.title': 'Memory Dream',
        'products.memory.description': 'Matelas en mousse mémoire pour un confort optimal',
        'products.spring.title': 'Classic Spring',
        'products.spring.description': 'Matelas à ressorts traditionnel confortable',
        'products.order': 'Commander',
        'products.from': 'À partir de',
        'products.dh': 'DH',
        'badge.bestseller': 'Bestseller',

        // Custom Order
        'custom.title': 'Tailles spéciales ? Design personnalisé ?',
        'custom.subtitle': 'Nous fabriquons des matelas selon vos besoins spécifiques',
        'custom.cta': 'Demander une consultation gratuite',

        // About
        'about.title': 'À propos d\'ALIDOR',
        'about.description': 'ALIDOR est un leader dans la fabrication de matelas de luxe au Maroc. Nous nous engageons à offrir la meilleure expérience de sommeil possible grâce à nos produits de haute qualité.',
        'about.quality': 'Haute qualité',
        'about.quality.desc': 'Nous utilisons les meilleurs matériaux et techniques',
        'about.comfort': 'Confort absolu',
        'about.comfort.desc': 'Design qui garantit un sommeil confortable',
        'about.custom': 'Tailles personnalisées',
        'about.custom.desc': 'Nous fabriquons selon vos besoins',

        // Story
        'story.title': 'Notre histoire',
        'story.p1': 'Le voyage d\'ALIDOR a commencé il y a plus de 15 ans avec une vision claire : fournir des matelas de haute qualité garantissant un sommeil confortable et sain pour tous.',
        'story.p2': 'Nous croyons qu\'un bon sommeil est la base d\'une vie saine, c\'est pourquoi nous utilisons les meilleurs matériaux et technologies modernes dans la fabrication de nos matelas.',
        'story.p3': 'Aujourd\'hui, nous sommes fiers d\'être l\'un des leaders dans l\'industrie du matelas au Maroc, et nous continuons d\'innover pour offrir le meilleur à nos clients.',
        'vision.title': 'Notre vision',
        'vision.text': 'Être le premier choix pour les matelas de luxe au Maroc',
        'mission.title': 'Notre mission',
        'mission.text': 'Améliorer la qualité du sommeil de chaque famille marocaine',

        // Statistics
        'stat.customers': 'clients satisfaits',
        'stat.experience': 'ans d\'expérience',
        'stat.cities': 'villes desservies',
        'stat.satisfaction': 'satisfaction client',

        // Contact
        'contact.title': 'Contactez-nous',
        'contact.subtitle': 'Nous sommes là pour vous aider à choisir le matelas parfait',
        'contact.info.title': 'Informations de contact',
        'contact.phone': 'Téléphone',
        'contact.whatsapp': 'WhatsApp',
        'contact.address': 'Adresse',
        'contact.address.value': 'Casablanca, Maroc',
        'contact.hours': 'Heures d\'ouverture',
        'contact.hours.value': 'Lundi - Samedi : 9h00 - 19h00',

        // Map
        'map.title': 'Notre emplacement',
        'map.placeholder': 'Carte interactive bientôt disponible',

        // Contact Form
        'form.title': 'Envoyez-nous un message',
        'form.name': 'Nom complet',
        'form.name.placeholder': 'Entrez votre nom complet',
        'form.phone': 'Numéro de téléphone',
        'form.phone.placeholder': '+212 6XX XXX XXX',
        'form.email': 'Adresse e-mail',
        'form.email.placeholder': 'exemple@email.com',
        'form.subject': 'Sujet du message',
        'form.subject.placeholder': 'Choisissez le sujet',
        'form.subject.order': 'Commande de matelas',
        'form.subject.custom': 'Taille personnalisée',
        'form.subject.support': 'Support technique',
        'form.subject.other': 'Autre',
        'form.message': 'Message',
        'form.message.placeholder': 'Écrivez votre message ici...',
        'form.submit': 'Envoyer le message',

        // Quick Actions
        'quick.title': 'Besoin d\'une réponse rapide ?',
        'quick.subtitle': 'Contactez-nous directement via WhatsApp pour une réponse immédiate',
        'quick.cta': 'Chattez avec nous maintenant',

        // Footer
        'footer.description': 'Entreprise leader dans la fabrication de matelas de luxe au Maroc. Nous nous engageons à offrir la meilleure expérience de sommeil possible.',
        'footer.address': 'Casablanca, Maroc',
        'footer.links.title': 'Liens rapides',
        'footer.products.title': 'Nos produits',
        'footer.newsletter.title': 'Suivez-nous',
        'footer.newsletter.desc': 'Abonnez-vous à notre newsletter pour recevoir les dernières offres',
        'footer.newsletter.placeholder': 'Votre adresse e-mail',
        'footer.newsletter.submit': 'S\'abonner',
        'footer.social.title': 'Suivez-nous sur les réseaux sociaux',
        'footer.year': '2025',
        'footer.rights': 'Tous droits réservés à ALIDOR',
        'footer.privacy': 'Politique de confidentialité',
        'footer.terms': 'Conditions d\'utilisation',
        'footer.made': 'Fabriqué avec',
        'footer.morocco': 'au Maroc',

        // Modal
        'modal.title': 'Commandez votre matelas maintenant',
        'modal.name': 'Nom complet',
        'modal.name.placeholder': 'Entrez votre nom complet',
        'modal.city': 'Ville',
        'modal.city.placeholder': 'Casablanca, Rabat, etc...',
        'modal.phone': 'Numéro de téléphone',
        'modal.phone.placeholder': '+212 6XX XXX XXX',
        'modal.size': 'Taille',
        'modal.size.placeholder': 'Choisissez la taille',
        'modal.size.single': '90×190 cm (lit simple)',
        'modal.size.single_large': '120×190 cm (lit simple large)',
        'modal.size.double_small': '140×190 cm (lit double petit)',
        'modal.size.double': '160×200 cm (lit double)',
        'modal.size.queen': '180×200 cm (lit queen)',
        'modal.size.king': '200×200 cm (lit king)',
        'modal.size.custom': 'Taille personnalisée',
        'modal.custom_size': 'Taille personnalisée',
        'modal.custom_size.placeholder': 'Exemple : 150×200 cm',
        'modal.cancel': 'Annuler',
        'modal.submit': 'Envoyer via WhatsApp',

        // Validation
        'validation.name': 'Veuillez entrer le nom',
        'validation.city': 'Veuillez entrer la ville',
        'validation.phone': 'Veuillez entrer un numéro de téléphone valide',
        'validation.size': 'Veuillez choisir la taille',
        'validation.custom_size': 'Veuillez entrer la taille personnalisée',

        // WhatsApp
        'whatsapp.tooltip.title': 'Chattez avec nous maintenant',
        'whatsapp.tooltip.text': 'Nous sommes disponibles pour répondre à vos questions et vous aider à choisir le matelas parfait',
        'whatsapp.tooltip.cta': 'Commencer la conversation',
        'whatsapp.mobile.cta': 'Contactez-nous via WhatsApp',
        'whatsapp.message': 'Bonjour, j\'aimerais me renseigner sur les matelas ALIDOR'
    }
};

// ===================================
// INITIALIZATION
// ===================================

document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
    loadUserPreferences();
    setupScrollEffects();
    setupWhatsAppPulse();
    preloadImages();
});

function initializeApp() {
    console.log('ALIDOR Website Initialized');
    
    // Set initial language and theme
    applyLanguage(currentLanguage);
    applyTheme(currentTheme);
    
    // Update language toggle buttons
    updateLanguageToggle();
    updateThemeToggle();
}

// ===================================
// EVENT LISTENERS
// ===================================

function setupEventListeners() {
    // Language toggle buttons
    document.getElementById('language-toggle').addEventListener('click', toggleLanguage);
    document.getElementById('mobile-language-toggle').addEventListener('click', toggleLanguage);
    
    // Theme toggle buttons
    document.getElementById('theme-toggle').addEventListener('click', toggleTheme);
    document.getElementById('mobile-theme-toggle').addEventListener('click', toggleTheme);
    
    // Mobile menu toggle
    document.getElementById('mobile-menu-toggle').addEventListener('click', toggleMobileMenu);
    
    // Navigation links
    setupNavigationLinks();
    
    // Form submissions
    setupFormSubmissions();
    
    // Modal events
    setupModalEvents();
    
    // Scroll events
    window.addEventListener('scroll', handleScroll);
    
    // Close modal on outside click
    document.getElementById('order-modal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeOrderModal();
        }
    });
    
    // Size selector change
    document.getElementById('order-size').addEventListener('change', handleSizeChange);
}

function setupNavigationLinks() {
    // Desktop navigation
    const navLinks = document.querySelectorAll('.nav-links a, .mobile-nav-links a, .footer-links a');
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            scrollToSection(targetId);
            
            // Close mobile menu if open
            const mobileNav = document.getElementById('mobile-nav');
            if (mobileNav.classList.contains('active')) {
                toggleMobileMenu();
            }
        });
    });
}

function setupFormSubmissions() {
    // Contact form
    document.getElementById('contact-form').addEventListener('submit', function(e) {
        e.preventDefault();
        handleContactFormSubmission(this);
    });
    
    // Newsletter form
    document.getElementById('newsletter-form').addEventListener('submit', function(e) {
        e.preventDefault();
        handleNewsletterSubmission(this);
    });
    
    // Order form
    document.getElementById('order-form').addEventListener('submit', function(e) {
        e.preventDefault();
        handleOrderFormSubmission(this);
    });
}

function setupModalEvents() {
    // Close modal with Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeOrderModal();
        }
    });
}

// ===================================
// LANGUAGE & THEME MANAGEMENT
// ===================================

function toggleLanguage() {
    currentLanguage = currentLanguage === 'ar' ? 'fr' : 'ar';
    applyLanguage(currentLanguage);
    updateLanguageToggle();
    saveUserPreferences();
}

function applyLanguage(language) {
    const html = document.documentElement;
    const body = document.body;
    
    if (language === 'ar') {
        html.lang = 'ar';
        html.dir = 'rtl';
        body.classList.remove('ltr');
        body.classList.add('rtl');
    } else {
        html.lang = 'fr';
        html.dir = 'ltr';
        body.classList.remove('rtl');
        body.classList.add('ltr');
    }
    
    // Update all translatable elements
    updateTranslations();
}

function updateLanguageToggle() {
    const langText = document.getElementById('lang-text');
    const mobileLangText = document.getElementById('mobile-lang-text');
    
    if (langText && mobileLangText) {
        const displayText = currentLanguage === 'ar' ? 'FR' : 'ع';
        langText.textContent = displayText;
        mobileLangText.textContent = displayText;
    }
}

function toggleTheme() {
    currentTheme = currentTheme === 'light' ? 'dark' : 'light';
    applyTheme(currentTheme);
    updateThemeToggle();
    saveUserPreferences();
}

function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
}

function updateThemeToggle() {
    const lightIcons = document.querySelectorAll('.theme-icon-light');
    const darkIcons = document.querySelectorAll('.theme-icon-dark');
    
    if (currentTheme === 'light') {
        lightIcons.forEach(icon => icon.style.display = 'block');
        darkIcons.forEach(icon => icon.style.display = 'none');
    } else {
        lightIcons.forEach(icon => icon.style.display = 'none');
        darkIcons.forEach(icon => icon.style.display = 'block');
    }
}

function updateTranslations() {
    const elements = document.querySelectorAll('[data-key]');
    elements.forEach(element => {
        const key = element.getAttribute('data-key');
        const translation = translations[currentLanguage][key];
        
        if (translation) {
            if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
                element.placeholder = translation;
            } else {
                element.textContent = translation;
            }
        }
    });
    
    // Update placeholders separately
    const placeholderElements = document.querySelectorAll('[data-placeholder]');
    placeholderElements.forEach(element => {
        const key = element.getAttribute('data-placeholder');
        const translation = translations[currentLanguage][key];
        
        if (translation) {
            element.placeholder = translation;
        }
    });
}

// ===================================
// USER PREFERENCES
// ===================================

function loadUserPreferences() {
    const savedLanguage = localStorage.getItem('alidor-language');
    const savedTheme = localStorage.getItem('alidor-theme');
    
    if (savedLanguage && (savedLanguage === 'ar' || savedLanguage === 'fr')) {
        currentLanguage = savedLanguage;
    }
    
    if (savedTheme && (savedTheme === 'light' || savedTheme === 'dark')) {
        currentTheme = savedTheme;
    }
    
    applyLanguage(currentLanguage);
    applyTheme(currentTheme);
    updateLanguageToggle();
    updateThemeToggle();
}

function saveUserPreferences() {
    localStorage.setItem('alidor-language', currentLanguage);
    localStorage.setItem('alidor-theme', currentTheme);
}

// ===================================
// NAVIGATION & SCROLLING
// ===================================

function toggleMobileMenu() {
    const mobileNav = document.getElementById('mobile-nav');
    const menuToggle = document.getElementById('mobile-menu-toggle');
    
    mobileNav.classList.toggle('active');
    menuToggle.classList.toggle('active');
}

function scrollToSection(sectionId) {
    const element = document.getElementById(sectionId);
    if (element) {
        const headerHeight = document.getElementById('header').offsetHeight;
        const elementPosition = element.offsetTop - headerHeight;
        
        window.scrollTo({
            top: elementPosition,
            behavior: 'smooth'
        });
    }
}

function scrollToTop() {
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    });
}

function handleScroll() {
    const backToTopBtn = document.getElementById('back-to-top');
    
    // Show/hide back to top button
    if (window.pageYOffset > 300) {
        backToTopBtn.classList.add('visible');
    } else {
        backToTopBtn.classList.remove('visible');
    }
    
    // Header scroll effect
    const header = document.getElementById('header');
    if (window.pageYOffset > 50) {
        header.style.background = currentTheme === 'dark' 
            ? 'rgba(15, 23, 42, 0.98)' 
            : 'rgba(255, 255, 255, 0.98)';
    } else {
        header.style.background = currentTheme === 'dark' 
            ? 'rgba(15, 23, 42, 0.95)' 
            : 'rgba(255, 255, 255, 0.95)';
    }
}

function setupScrollEffects() {
    // Intersection Observer for animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-fade-in-up');
            }
        });
    }, observerOptions);
    
    // Observe elements for animation
    const animateElements = document.querySelectorAll('.product-card, .about-feature, .stat, .contact-item');
    animateElements.forEach(el => observer.observe(el));
}

// ===================================
// PRODUCT MODAL
// ===================================

function openOrderModal(productId = null) {
    if (productId && products[productId]) {
        currentProduct = products[productId];
        populateModalWithProduct(currentProduct);
    }
    
    document.getElementById('order-modal').classList.add('active');
    document.body.style.overflow = 'hidden';
    
    // Reset form
    document.getElementById('order-form').reset();
    clearFormErrors();
    hideCustomSizeField();
}

function closeOrderModal() {
    document.getElementById('order-modal').classList.remove('active');
    document.body.style.overflow = '';
    currentProduct = null;
    currentImageIndex = 0;
}

function populateModalWithProduct(product) {
    if (!product) return;
    
    // Update product details
    document.getElementById('modal-product-name').textContent = product.name[currentLanguage];
    document.getElementById('modal-product-description').textContent = product.description[currentLanguage];
    document.getElementById('modal-product-price').textContent = product.price;
    
    // Update images
    document.getElementById('modal-main-image').src = product.images[0];
    document.getElementById('modal-thumb-1').src = product.images[0];
    document.getElementById('modal-thumb-2').src = product.images[1];
    document.getElementById('modal-thumb-3').src = product.images[2];
    
    // Reset image selection
    currentImageIndex = 0;
    updateImageSelection();
}

function changeModalImage(index) {
    if (!currentProduct || !currentProduct.images[index]) return;
    
    currentImageIndex = index;
    document.getElementById('modal-main-image').src = currentProduct.images[index];
    updateImageSelection();
}

function updateImageSelection() {
    const thumbnails = document.querySelectorAll('.thumbnail');
    thumbnails.forEach((thumb, index) => {
        if (index === currentImageIndex) {
            thumb.classList.add('active');
        } else {
            thumb.classList.remove('active');
        }
    });
}

function handleSizeChange() {
    const sizeSelect = document.getElementById('order-size');
    const customSizeGroup = document.getElementById('custom-size-group');
    
    if (sizeSelect.value === 'custom') {
        showCustomSizeField();
    } else {
        hideCustomSizeField();
    }
}

function showCustomSizeField() {
    document.getElementById('custom-size-group').style.display = 'block';
    document.getElementById('custom-size').required = true;
}

function hideCustomSizeField() {
    document.getElementById('custom-size-group').style.display = 'none';
    document.getElementById('custom-size').required = false;
    document.getElementById('custom-size').value = '';
}

// ===================================
// FORM HANDLING
// ===================================

function handleOrderFormSubmission(form) {
    clearFormErrors();
    
    const formData = new FormData(form);
    const orderData = {
        name: formData.get('name').trim(),
        city: formData.get('city').trim(),
        phone: formData.get('phone').trim(),
        size: formData.get('size'),
        customSize: formData.get('custom_size')?.trim() || ''
    };
    
    // Validate form
    if (!validateOrderForm(orderData)) {
        return;
    }
    
    // Generate WhatsApp message
    const whatsappMessage = generateOrderWhatsAppMessage(orderData);
    const whatsappURL = `https://wa.me/212681235145?text=${encodeURIComponent(whatsappMessage)}`;
    
    // Open WhatsApp
    window.open(whatsappURL, '_blank');
    
    // Close modal
    closeOrderModal();
    
    // Show success message
    showNotification(translations[currentLanguage]['modal.submit'] || 'تم إرسال الطلب بنجاح!', 'success');
}

function validateOrderForm(data) {
    let isValid = true;
    
    // Validate name
    if (!data.name) {
        showFormError('name-error', translations[currentLanguage]['validation.name']);
        isValid = false;
    }
    
    // Validate city
    if (!data.city) {
        showFormError('city-error', translations[currentLanguage]['validation.city']);
        isValid = false;
    }
    
    // Validate phone
    if (!data.phone) {
        showFormError('phone-error', translations[currentLanguage]['validation.phone']);
        isValid = false;
    } else if (!isValidMoroccanPhone(data.phone)) {
        showFormError('phone-error', translations[currentLanguage]['validation.phone']);
        isValid = false;
    }
    
    // Validate size
    if (!data.size) {
        showFormError('size-error', translations[currentLanguage]['validation.size']);
        isValid = false;
    } else if (data.size === 'custom' && !data.customSize) {
        showFormError('custom-size-error', translations[currentLanguage]['validation.custom_size']);
        isValid = false;
    }
    
    return isValid;
}

function isValidMoroccanPhone(phone) {
    // Remove spaces and special characters
    const cleanPhone = phone.replace(/[\s\-\(\)]/g, '');
    
    // Check Moroccan phone patterns
    const patterns = [
        /^(\+212|0)[5-7]\d{8}$/,  // Morocco mobile numbers
        /^(\+212|0)5\d{8}$/       // Morocco landline numbers
    ];
    
    return patterns.some(pattern => pattern.test(cleanPhone));
}

function generateOrderWhatsAppMessage(orderData) {
    const productName = currentProduct ? currentProduct.name[currentLanguage] : '';
    const productPrice = currentProduct ? currentProduct.price : '';
    
    let sizeText = '';
    if (orderData.size === 'custom') {
        sizeText = `${translations[currentLanguage]['modal.size.custom']}: ${orderData.customSize}`;
    } else {
        sizeText = translations[currentLanguage][`modal.size.${orderData.size.replace('x', '_')}`] || orderData.size;
    }
    
    const message = currentLanguage === 'ar' ? `
مرحباً، أود طلب مرتبة من ALIDOR

📋 تفاصيل الطلب:
• المنتج: ${productName}
• السعر: ${productPrice} درهم
• المقاس: ${sizeText}

👤 معلومات العميل:
• الاسم: ${orderData.name}
• المدينة: ${orderData.city}
• الهاتف: ${orderData.phone}

أرجو التواصل معي لتأكيد الطلب وترتيب التوصيل.

شكراً لكم 🙏
    `.trim() : `
Bonjour, je souhaite commander un matelas ALIDOR

📋 Détails de la commande:
• Produit: ${productName}
• Prix: ${productPrice} DH
• Taille: ${sizeText}

👤 Informations client:
• Nom: ${orderData.name}
• Ville: ${orderData.city}
• Téléphone: ${orderData.phone}

Merci de me contacter pour confirmer la commande et organiser la livraison.

Merci 🙏
    `.trim();
    
    return message;
}

function handleContactFormSubmission(form) {
    const formData = new FormData(form);
    const contactData = {
        name: formData.get('name').trim(),
        phone: formData.get('phone').trim(),
        email: formData.get('email').trim(),
        subject: formData.get('subject'),
        message: formData.get('message').trim()
    };
    
    // Basic validation
    if (!contactData.name || !contactData.phone || !contactData.message) {
        showNotification('يرجى ملء جميع الحقول المطلوبة', 'error');
        return;
    }
    
    // Generate WhatsApp message for contact
    const whatsappMessage = generateContactWhatsAppMessage(contactData);
    const whatsappURL = `https://wa.me/212681235145?text=${encodeURIComponent(whatsappMessage)}`;
    
    // Open WhatsApp
    window.open(whatsappURL, '_blank');
    
    // Reset form
    form.reset();
    
    // Show success message
    showNotification('تم إرسال رسالتك بنجاح!', 'success');
}

function generateContactWhatsAppMessage(contactData) {
    const subjectText = translations[currentLanguage][`form.subject.${contactData.subject}`] || contactData.subject;
    
    const message = currentLanguage === 'ar' ? `
مرحباً، لدي استفسار حول ALIDOR

📝 تفاصيل الرسالة:
• الموضوع: ${subjectText}
• الرسالة: ${contactData.message}

👤 معلومات المرسل:
• الاسم: ${contactData.name}
• الهاتف: ${contactData.phone}
${contactData.email ? `• البريد الإلكتروني: ${contactData.email}` : ''}

شكراً لكم
    `.trim() : `
Bonjour, j'ai une question concernant ALIDOR

📝 Détails du message:
• Sujet: ${subjectText}
• Message: ${contactData.message}

👤 Informations de l'expéditeur:
• Nom: ${contactData.name}
• Téléphone: ${contactData.phone}
${contactData.email ? `• E-mail: ${contactData.email}` : ''}

Merci
    `.trim();
    
    return message;
}

function handleNewsletterSubmission(form) {
    const formData = new FormData(form);
    const email = formData.get('email').trim();
    
    if (!email || !isValidEmail(email)) {
        showNotification('يرجى إدخال بريد إلكتروني صحيح', 'error');
        return;
    }
    
    // Simulate newsletter subscription
    form.reset();
    showNotification('تم الاشتراك في النشرة البريدية بنجاح!', 'success');
}

function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function showFormError(errorId, message) {
    const errorElement = document.getElementById(errorId);
    if (errorElement) {
        errorElement.textContent = message;
        errorElement.classList.add('active');
    }
}

function clearFormErrors() {
    const errorElements = document.querySelectorAll('.form-error');
    errorElements.forEach(element => {
        element.classList.remove('active');
        element.textContent = '';
    });
}

// ===================================
// WHATSAPP INTEGRATION
// ===================================

function openWhatsApp() {
    const message = translations[currentLanguage]['whatsapp.message'];
    const whatsappURL = `https://wa.me/212681235145?text=${encodeURIComponent(message)}`;
    window.open(whatsappURL, '_blank');
}

function setupWhatsAppPulse() {
    const whatsappBtn = document.querySelector('.whatsapp-btn');
    if (whatsappBtn) {
        // Add pulse animation every 5 seconds
        setInterval(() => {
            whatsappBtn.style.animation = 'none';
            setTimeout(() => {
                whatsappBtn.style.animation = 'pulse-whatsapp 2s ease-in-out';
            }, 100);
        }, 5000);
    }
}

// ===================================
// UTILITY FUNCTIONS
// ===================================

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#22c55e' : type === 'error' ? '#ef4444' : '#2563eb'};
        color: white;
        padding: 16px 24px;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        z-index: 9999;
        transform: translateX(100%);
        transition: transform 0.3s ease;
        max-width: 300px;
        font-weight: 600;
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    // Show notification
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Hide notification after 3 seconds
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

function preloadImages() {
    // Preload product images
    Object.values(products).forEach(product => {
        product.images.forEach(imageSrc => {
            const img = new Image();
            img.src = imageSrc;
        });
    });
    
    // Preload background images
    const backgroundImages = [
        'images/hero_background.jpeg',
        'images/about_background.png'
    ];
    
    backgroundImages.forEach(imageSrc => {
        const img = new Image();
        img.src = imageSrc;
    });
}

function quickView(productId) {
    openOrderModal(productId);
}

function addToFavorites(productId) {
    showNotification('تمت إضافة المنتج إلى المفضلة!', 'success');
}

function openCustomOrderModal() {
    const message = currentLanguage === 'ar' 
        ? 'مرحباً، أود الاستفسار عن المقاسات المخصصة والتصميم الخاص للمراتب'
        : 'Bonjour, je souhaite me renseigner sur les tailles personnalisées et le design spécial pour les matelas';
    
    const whatsappURL = `https://wa.me/212681235145?text=${encodeURIComponent(message)}`;
    window.open(whatsappURL, '_blank');
}

// ===================================
// SEARCH FUNCTIONALITY (Optional)
// ===================================

function initializeSearch() {
    // This can be implemented if search functionality is needed
    console.log('Search functionality can be added here');
}

// ===================================
// PERFORMANCE OPTIMIZATION
// ===================================

// Lazy loading for images
function setupLazyLoading() {
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.classList.remove('lazy');
                    imageObserver.unobserve(img);
                }
            });
        });
        
        document.querySelectorAll('img[data-src]').forEach(img => {
            imageObserver.observe(img);
        });
    }
}

// Debounce function for scroll events
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// ===================================
// ERROR HANDLING
// ===================================

window.addEventListener('error', function(e) {
    console.error('JavaScript Error:', e.error);
    // Handle errors gracefully without breaking the user experience
});

window.addEventListener('unhandledrejection', function(e) {
    console.error('Unhandled Promise Rejection:', e.reason);
    // Handle promise rejections gracefully
});

// ===================================
// ANALYTICS (Optional)
// ===================================

function trackEvent(eventName, eventData = {}) {
    // This can be implemented with Google Analytics or other tracking services
    console.log('Event tracked:', eventName, eventData);
}

// Track page load
window.addEventListener('load', function() {
    trackEvent('page_load', {
        language: currentLanguage,
        theme: currentTheme,
        timestamp: new Date().toISOString()
    });
});

// ===================================
// ACCESSIBILITY IMPROVEMENTS
// ===================================

// Keyboard navigation support
document.addEventListener('keydown', function(e) {
    // Handle keyboard navigation for modals
    if (e.key === 'Tab') {
        const modal = document.getElementById('order-modal');
        if (modal.classList.contains('active')) {
            // Trap focus within modal
            trapFocusInModal(e, modal);
        }
    }
});

function trapFocusInModal(e, modal) {
    const focusableElements = modal.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];
    
    if (e.shiftKey && document.activeElement === firstElement) {
        e.preventDefault();
        lastElement.focus();
    } else if (!e.shiftKey && document.activeElement === lastElement) {
        e.preventDefault();
        firstElement.focus();
    }
}

// Announce screen reader messages
function announceToScreenReader(message) {
    const announcement = document.createElement('div');
    announcement.setAttribute('aria-live', 'polite');
    announcement.setAttribute('aria-atomic', 'true');
    announcement.className = 'sr-only';
    announcement.textContent = message;
    
    document.body.appendChild(announcement);
    
    setTimeout(() => {
        document.body.removeChild(announcement);
    }, 1000);
}

// ===================================
// EXPORT FUNCTIONS (for testing)
// ===================================

// Make functions available globally for testing
window.ALIDOR = {
    openOrderModal,
    closeOrderModal,
    toggleLanguage,
    toggleTheme,
    openWhatsApp,
    scrollToSection,
    scrollToTop,
    quickView,
    addToFavorites,
    openCustomOrderModal
};

console.log('ALIDOR JavaScript loaded successfully');
