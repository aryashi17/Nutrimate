class HealthTrivia {
  static final Map<int, List<Map<String, String>>> _monthlyThemes = {
    1: [ // January: Bone & Joint Health
      {"q": "What mineral makes up 99% of your teeth and bones?", "a": "Calcium! Found in the milk and curd you have at breakfast."},
      {"q": "How many bones does an adult human have?", "a": "206! Keep them strong with Vitamin D and exercise."},
      {"q": "What is the smallest bone in the human body?", "a": "The Stapes (in your ear)! It's only 3mm long."},
    ],
    2: [ // February: Brain & Focus
      {"q": "Which healthy fat makes up 60% of your brain?", "a": "Omega-3! Found in walnuts and flaxseeds."},
      {"q": "How many neurons are in the human brain?", "a": "About 86 billion! Feed them with complex carbs for focus."},
      {"q": "What percentage of your body's oxygen does your brain use?", "a": "20%! Deep breathing helps you study better."},
    ],
    3: [ // March: Hydration
      {"q": "How much of the human brain is actually made of water?", "a": "About 75%! Staying hydrated is key for focus."},
      {"q": "What is the first sign of dehydration?", "a": "Fatigue and thirst. Drink water before you feel tired!"},
    ],
    4: [ // April: Muscle & Protein
      {"q": "What is the largest muscle in the human body?", "a": "The Gluteus Maximus! It helps you stand and walk."},
      {"q": "Which nutrient is the building block of muscle?", "a": "Protein! Essential for repair after the gym."},
    ],
    5: [ // May: Heart Health
      {"q": "How many times does your heart beat in a day?", "a": "About 100,000 times! Keep it healthy with cardio."},
      {"q": "Which mineral helps regulate your heartbeat?", "a": "Potassium! Found in bananas and potatoes."},
    ],
    6: [ // June: Skin & Sun
      {"q": "What is the largest organ in the human body?", "a": "The Skin! Protein is vital for keeping it healthy."},
      {"q": "Which vitamin is known as the 'Sunshine Vitamin'?", "a": "Vitamin D! Your skin makes it from sunlight."},
    ],
    7: [ // July: Digestion
      {"q": "Which 'good' bacteria in curd helps your digestion?", "a": "Probiotics! They keep your gut microbiome balanced."},
      {"q": "What nutrient helps move food through your system?", "a": "Fiber! Found in whole grains and vegetables."},
    ],
    8: [ // August: Respiratory
      {"q": "How many breaths does an average person take daily?", "a": "About 22,000 breaths!"},
      {"q": "Which lung is slightly smaller to make room for the heart?", "a": "The left lung!"},
    ],
    9: [ // September: Blood
      {"q": "Which mineral in Spinach helps transport oxygen in blood?", "a": "Iron! Low iron can make you feel weak and tired."},
      {"q": "How long does it take for blood to circle the body?", "a": "About 60 seconds!"},
    ],
    10: [ // October: Vision
      {"q": "Which vitamin is most important for night vision?", "a": "Vitamin A! Found in carrots and sweet potatoes."},
      {"q": "True or False: Your eyes stay the same size from birth?", "a": "True! Eyes don't grow much unlike ears."},
    ],
    11: [ // November: Sleep
      {"q": "What hormone helps regulate your sleep-wake cycle?", "a": "Melatonin! It increases when it gets dark."},
      {"q": "How many hours of sleep do college students need?", "a": "7 to 9 hours for optimal brain function."},
    ],
    12: [ // December: Immunity (Current Month)
      {"q": "Which fruit has more Vitamin C than an orange?", "a": "Guava or Bell Peppers! Great for fighting colds."},
      {"q": "Which common spice in Dal is anti-inflammatory?", "a": "Turmeric (Haldi)! It boosts your immunity."},
      {"q": "True or False: Shivering burns calories?", "a": "True! Your body generates heat through muscle contraction."},
    ],
  };

  static Map<String, String> getTodaysTrivia() {
    final now = DateTime.now();
    final monthQuestions = _monthlyThemes[now.month] ?? _monthlyThemes[1]!;
    
    // Day-based rotation ensures a new question every day
    int index = (now.day - 1) % monthQuestions.length;
    return monthQuestions[index];
  }
}