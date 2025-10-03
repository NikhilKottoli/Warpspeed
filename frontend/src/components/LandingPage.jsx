import React, { useState, useEffect } from 'react';
import { Cloud, DollarSign, Building2 } from 'lucide-react';

// NOTE: For a real shadcn project, you would typically use components like
// <Button>, <Card>, etc., but since we are modifying a single file,
// we will primarily apply the shadcn *color and style* philosophy using Tailwind classes.

const LandingPage = () => {
  const [scrollY, setScrollY] = useState(0);
  const [isVisible, setIsVisible] = useState({});
  const [featuresData, setFeaturesData] = useState({ features: [] });

  // Icon mapping (Simplified, keeping only the used ones for brevity)
  const iconMap = {
    Cloud,
    DollarSign,
    Building2,
  };

  // Load features from simulated JSON
  useEffect(() => {
    const loadFeatures = () => {
      const response = {
        "features": [
          {
            "id": "weather-forecast",
            "icon": "Cloud",
            "title": "Real-time Weather",
            "description": "Accurate 7-day predictions, hyper-local rainfall alerts, and climate insights for proactive farming.",
            "enabled": true
          },
          {
            "id": "msp-prices",
            "icon": "DollarSign",
            "title": "Market Price Insights",
            "description": "Stay updated with the latest Minimum Support Prices (MSP) and local mandi rates for informed selling decisions.",
            "enabled": true
          },
          {
            "id": "government-schemes",
            "icon": "Building2",
            "title": "Subsidy Access",
            "description": "Comprehensive, searchable database of agricultural subsidies, loans, and government welfare programs.",
            "enabled": true
          }
        ]
      };
      setFeaturesData(response);
    };

    loadFeatures();
  }, []);

  // Filter enabled features and convert icon string to component
  const features = featuresData.features
    .filter(feature => feature.enabled)
    .map(feature => ({
      ...feature,
      icon: iconMap[feature.icon] || Cloud
    }));

  // Handle scroll for parallax and navbar effects
  useEffect(() => {
    const handleScroll = () => setScrollY(window.scrollY);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Intersection Observer for animations
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsVisible(prev => ({
              ...prev,
              [entry.target.id]: true
            }));
          }
        });
      },
      // Lower threshold for early animation trigger
      { threshold: 0.05 }
    );

    const elements = document.querySelectorAll('[data-animate]');
    elements.forEach(el => observer.observe(el));

    return () => observer.disconnect();
  }, []);

  // Floating particles component (Simplified and color-adjusted for subtle effect)
  const FloatingParticles = () => {
    const particles = Array.from({ length: 20 }, (_, i) => (
      <div
        key={i}
        className="absolute bg-primary/20 rounded-full animate-pulse"
        style={{
          width: Math.random() * 4 + 2 + 'px',
          height: Math.random() * 4 + 2 + 'px',
          left: Math.random() * 100 + '%',
          top: Math.random() * 100 + '%',
          animationDelay: Math.random() * 3 + 's',
          animationDuration: Math.random() * 2 + 3 + 's'
        }}
      />
    ));
    return <div className="fixed inset-0 pointer-events-none overflow-hidden">{particles}</div>;
  };

  const handleExploreClick = () => {
    document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <div className="bg-background text-foreground overflow-x-hidden font-sans">
      <FloatingParticles />
      
      {/* Navigation */}
      <nav className={`fixed top-0 w-full z-50 transition-all duration-300 ${
        scrollY > 50 ? 'bg-background/90 backdrop-blur-lg shadow-sm border-b border-border' : 'bg-transparent'
      }`}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="text-xl font-bold text-primary">
              🌾 KRISHISATHI
            </div>
            <div className="hidden md:flex space-x-6">
              {['Home', 'Features', 'Team', 'Contact'].map((item) => (
                <a
                  key={item}
                  href={`#${item.toLowerCase()}`}
                  className="relative group text-foreground/80 hover:text-primary transition-colors duration-300 text-sm font-medium"
                >
                  {item}
                  <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-primary group-hover:w-full transition-all duration-300"></span>
                </a>
              ))}
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section 
        id="home"
        className="min-h-screen flex items-center justify-center relative bg-background pt-24"
        // Reduced parallax effect for a more subtle, modern feel
        style={{ transform: `translateY(${scrollY * 0.1}px)` }}
      >
        <div className="text-center z-10 px-4 max-w-4xl mx-auto">
          <h1 className="text-6xl md:text-8xl font-extrabold mb-6 tracking-tight text-foreground">
            KRISHISATHI
          </h1>
          <p className="text-xl md:text-2xl mb-4 text-muted-foreground">
            Your Digital Companion for **Smart Farming**
          </p>
          <p className="text-lg mb-8 text-foreground/70 max-w-2xl mx-auto">
            Leveraging AI and Data to optimize crop cycles, maximize yields, and ensure market readiness for every farmer.
          </p>
          <button 
            onClick={handleExploreClick}
            // Uses shadcn primary button styling
            className="group relative px-8 py-3 bg-primary text-primary-foreground rounded-lg text-base font-semibold transition-all duration-300 hover:bg-primary/90 shadow-md hover:shadow-lg"
          >
            <span className="relative z-10">Explore Solutions</span>
          </button>
        </div>
        
        {/* Simplified and cleaner wave */}
        <div className="absolute bottom-0 left-0 w-full">
          <svg viewBox="0 0 1200 120" preserveAspectRatio="none" className="w-full h-16">
            <path d="M0,48 C240,64 480,48 720,48 C960,48 1200,64 1200,48 L1200,120 L0,120 Z" fill="hsl(var(--muted))" />
          </svg>
        </div>
      </section>

      {/* Features Section */}
      <section 
        id="features" 
        data-animate 
        className="py-20 bg-muted relative"
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl md:text-4xl font-bold text-center mb-16 text-foreground">
            Empowering Farmers with Data
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div
                  key={feature.id}
                  id="features" // ID is moved here for observer
                  className={`group bg-card p-6 rounded-xl border border-border shadow-sm transition-all duration-500 hover:shadow-lg transform ${
                    isVisible.features ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
                  }`}
                  style={{ 
                    transitionDelay: `${index * 100}ms`,
                    transition: 'all 0.6s ease-out'
                  }}
                >
                  <div className="flex items-start">
                    {/* Icon style uses primary color for focus */}
                    <div className="p-3 mr-4 rounded-full bg-primary/10 text-primary group-hover:bg-primary/20 transition-colors duration-300">
                      <Icon className="w-6 h-6" />
                    </div>
                    <div>
                      <h3 className="text-lg font-semibold mb-2 text-card-foreground">{feature.title}</h3>
                      <p className="text-sm text-muted-foreground leading-relaxed">{feature.description}</p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section 
        id="team" 
        data-animate 
        className="py-20 bg-background relative"
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl md:text-4xl font-bold text-center mb-16 text-foreground">
            Dedicated to the Vision
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-12 max-w-4xl mx-auto">
            {[
              {
                name: "Mohnish Hemanth Kumar",
                image: "https://via.placeholder.com/150x150/10b981/ffffff?text=MHK"
              },
              {
                name: "Nikhil Kottoli",
                image: "/Nikhil.jpeg"
              },
              {
                name: "Yashwanth R",
                image: "/Yashwanth.jpeg"
              }
            ].map((member, index) => (
              <div
                key={member.name}
                id="team" // ID is moved here for observer
                className={`text-center transform ${
                  isVisible.team ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                }`}
                style={{ 
                  transitionDelay: `${index * 150}ms`,
                  transition: 'all 0.6s ease-out'
                }}
              >
                <img
                  src={member.image}
                  alt={member.name}
                  className="w-32 h-32 mx-auto rounded-full object-cover border-4 border-border hover:border-primary transition-all duration-300 hover:scale-[1.02] shadow-md"
                />
                
                <h3 className="text-lg font-semibold mt-4 text-foreground">
                  {member.name}
                </h3>
                <p className="text-sm text-muted-foreground">Co-founder</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-card border-t border-border py-6">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <p className="text-muted-foreground text-sm">&copy; 2025 KRISHISATHI. Empowering farmers through technology.</p>
            <p className="text-muted-foreground text-xs mt-1">Built with React and a modern UI philosophy.</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;