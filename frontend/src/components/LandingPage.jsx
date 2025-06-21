import React, { useState, useEffect } from 'react';
import { Cloud, DollarSign, Building2, TrendingUp, Leaf, Smartphone, Wifi, Users, Database, Shield } from 'lucide-react';

const LandingPage = () => {
  const [scrollY, setScrollY] = useState(0);
  const [isVisible, setIsVisible] = useState({});
  const [featuresData, setFeaturesData] = useState({ features: [] });

  // Icon mapping for string to component conversion
  const iconMap = {
    Cloud,
    DollarSign,
    Building2,
    TrendingUp,
    Leaf,
    Smartphone,
    Wifi,
    Users,
    Database,
    Shield
  };

  // Load features from JSON file
  useEffect(() => {
    const loadFeatures = async () => {
      try {
        // In a real project, you would fetch from './features.json'
        // For this demo, we'll simulate loading the JSON data
        const response = {
          "features": [
            {
              "id": "weather-forecast",
              "icon": "Cloud",
              "title": "Weather Forecast",
              "description": "Get accurate 7-day weather predictions, rainfall alerts, and climate insights to plan your farming activities better.",
              "enabled": true
            },
            {
              "id": "msp-prices",
              "icon": "DollarSign",
              "title": "MSP Prices",
              "description": "Stay updated with the latest Minimum Support Prices for all crops and make informed selling decisions.",
              "enabled": true
            },
            {
              "id": "government-schemes",
              "icon": "Building2",
              "title": "Government Schemes",
              "description": "Access comprehensive information about agricultural subsidies, loans, and government welfare programs.",
              "enabled": true
            }
          ]
        };
        setFeaturesData(response);
      } catch (error) {
        console.error('Error loading features:', error);
      }
    };

    loadFeatures();
  }, []);

  // Filter enabled features and convert to component-ready format
  const features = featuresData.features
    .filter(feature => feature.enabled)
    .map(feature => ({
      ...feature,
      icon: iconMap[feature.icon] || Cloud // fallback to Cloud if icon not found
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
      { threshold: 0.1 }
    );

    const elements = document.querySelectorAll('[data-animate]');
    elements.forEach(el => observer.observe(el));

    return () => observer.disconnect();
  }, []);

  // Floating particles component
  const FloatingParticles = () => {
    const particles = Array.from({ length: 30 }, (_, i) => (
      <div
        key={i}
        className="absolute bg-green-400/10 rounded-full animate-pulse"
        style={{
          width: Math.random() * 6 + 2 + 'px',
          height: Math.random() * 6 + 2 + 'px',
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
    <div className="bg-white text-gray-800 overflow-x-hidden">
      <FloatingParticles />
      
      {/* Navigation */}
      <nav className={`fixed top-0 w-full z-50 transition-all duration-300 ${
        scrollY > 50 ? 'bg-white/95 backdrop-blur-lg shadow-lg' : 'bg-white/90 backdrop-blur-sm'
      }`}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="text-2xl font-bold text-green-600">
              🌾 KRISHISATHI
            </div>
            <div className="hidden md:flex space-x-8">
              {['Home', 'Features', 'About', 'Contact'].map((item) => (
                <a
                  key={item}
                  href={`#${item.toLowerCase()}`}
                  className="relative group text-gray-700 hover:text-green-600 transition-colors duration-300"
                >
                  {item}
                  <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-green-600 group-hover:w-full transition-all duration-300"></span>
                </a>
              ))}
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section 
        id="home"
        className="min-h-screen flex items-center justify-center relative bg-gradient-to-br from-green-50 to-emerald-50"
        style={{ transform: `translateY(${scrollY * 0.3}px)` }}
      >
        <div className="text-center z-10 px-4 max-w-4xl mx-auto">
          <h1 className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 bg-clip-text text-transparent">
            KRISHISATHI
          </h1>
          <p className="text-xl md:text-2xl mb-4 text-gray-600">
            Your Digital Companion for Smart Farming
          </p>
          <p className="text-lg mb-8 text-gray-500">
            Real-time Weather • MSP Prices • Government Schemes • Agricultural Insights
          </p>
          <button 
            onClick={handleExploreClick}
            className="group relative px-8 py-4 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full text-lg font-semibold text-white transition-all duration-300 hover:scale-105 hover:shadow-2xl hover:shadow-green-500/25"
          >
            <span className="relative z-10">Explore Features</span>
            <div className="absolute inset-0 bg-gradient-to-r from-green-400 to-emerald-400 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            <div className="absolute inset-0 bg-white/20 rounded-full scale-0 group-hover:scale-100 transition-transform duration-500"></div>
          </button>
        </div>
        
        {/* Animated wave */}
        <div className="absolute bottom-0 left-0 w-full">
          <svg viewBox="0 0 1200 120" preserveAspectRatio="none" className="w-full h-20">
            <path d="M0,60 C300,120 900,0 1200,60 L1200,120 L0,120 Z" fill="#bbf7d0" />
          </svg>
        </div>
      </section>

      {/* Features Section */}
      <section 
        id="features" 
        data-animate 
        className="py-20 bg-gray-50 relative"
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-4xl md:text-5xl font-bold text-center mb-16 bg-gradient-to-r from-green-500 to-emerald-500 bg-clip-text text-transparent">
            Empowering Farmers with Technology
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div
                  key={feature.id}
                  className={`group relative bg-white p-8 rounded-2xl border border-gray-200 shadow-lg transition-all duration-500 hover:scale-105 hover:shadow-xl hover:shadow-green-500/10 transform ${
                    isVisible.features ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                  }`}
                  style={{ 
                    transitionDelay: `${index * 100}ms`,
                    transition: 'all 0.6s ease-out'
                  }}
                >
                  {/* Gradient border on hover */}
                  <div className="absolute inset-0 bg-gradient-to-r from-green-400 to-emerald-400 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300 -z-10"></div>
                  <div className="absolute inset-0.5 bg-white rounded-2xl"></div>
                  
                  <div className="text-center relative z-10">
                    <Icon className="w-12 h-12 mx-auto mb-4 text-green-500 group-hover:scale-110 transition-transform duration-300" />
                    <h3 className="text-xl font-semibold mb-4 text-green-600">{feature.title}</h3>
                    <p className="text-gray-600 leading-relaxed">{feature.description}</p>
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
        className="py-20 bg-white relative"
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-4xl md:text-5xl font-bold text-center mb-16 bg-gradient-to-r from-green-500 to-emerald-500 bg-clip-text text-transparent">
            Meet Our Team
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
                  className="w-32 h-32 mx-auto rounded-full border-4 border-green-200 hover:border-green-400 transition-all duration-300 hover:scale-105 shadow-lg"
                />
                
                <h3 className="text-lg font-semibold mt-4 text-gray-800">
                  {member.name}
                </h3>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-800 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <p className="text-white/80">&copy; 2025 KRISHISATHI. Empowering farmers through technology.</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;