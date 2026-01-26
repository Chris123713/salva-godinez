export default {
  Language: "en",
  ServerInfo: {
    name: "Sierra Valley Roleplay",
    description: "Where Dreams Come True",
    logoSpin: true, // Set to false to disable logo spinning animation
  },

  // Background Video Configuration
  // IF BOTH ARE EMPTY, IT FALLBACKS TO LOCAL VIDEO
  Video: {
    // YouTube video ID (e.g., "4BSZtvqfzWE" from https://www.youtube.com/watch?v=4BSZtvqfzWE)
    // Leave empty to use local video
    youtubeId: "", // Example: "4BSZtvqfzWE"

    // Or use a direct video URL (mp4, webm, etc.)
    // Leave empty to use local video
    directUrl: "https://cdn.discordapp.com/attachments/1444139664033448086/1451146830720012400/Christmas_in_Serria_Valley.mp4?ex=694fa94d&is=694e57cd&hm=8e0de56f805542271c68b90970dcca03cec6d14c778bd793aa018a6ad40994e1&", // Christmas in Sierra Valley

    // Local video file name (if both youtubeId and directUrl are empty)
    // Should be in web/dist/ folder (fallbacks to web/dist/bg.mp4)
    localFile: "", // Example: "bg.mp4"
  },

  // Image Slideshow Configuration (Alternative to video background)
  Images: {
    enabled: false, // Set to true to use images instead of video
    interval: 5000, // Time between image transitions in milliseconds
    transition: "fade", // "fade", "slide", "zoom"
    transitionDuration: 1000, // Transition duration in milliseconds
    images: [
      // Add your images here, they should be PNG files in web/dist/slideshow/ folder
      // Example: "image1.png", "image2.png", "image3.png"
      'advanced-banking.png',
      'advanced-garages.png',
      'advanced-housing.png',
    ],
  },

  // IF source IS "local", IT FALLBACKS TO LOCAL AUDIO
  // IF source IS "video", IT USES THE AUDIO FROM THE VIDEO
  // IF source IS "playlist", IT USES THE PLAYLIST
  Audio: {
    source: "video", // "local", "video", or "playlist"

    // Local audio configuration (if source is "local")
    // File should be in web/dist/ folder
    local: {
      file: "audio.mp3",  // Audio file name (e.g., "audio.mp3")
      title: "EDM Gaming",          // Optional: Song title to display
      artist: "sapan4"          // Optional: Artist name to display
    },

    // Video audio information (if source is "video")
    // Optional: Display title/artist when using video's audio
    video: {
      title: "Gaming",          // Optional: Song title to display
      artist: "song"          // Optional: Artist name to display
    },

    // Playlist configuration (if source is "playlist")
    playlist: {
      shuffle: false, // Enable shuffle mode
      showInfo: true, // Show current song title and artist
      tracks: [
        // MP3 files should be in web/dist/playlist/ folder
        // Use format: { file: "filename.mp3", title: "Song Title", artist: "Artist Name" }
        { file: "edm.mp3", title: "EDM Gaming", artist: "sapan4" },
        { file: "gaming.mp3", title: "Gaming Song", artist: "BackgroundMusicForVideos" },
        { file: "retro.mp3", title: "Retro Vibes", artist: "YaKaStreams" },
      ],
    },

    defaultVolume: 50, // 0-100
  },

  SocialLinks: [
    {
      icon: "pi pi-discord",
      url: "https://discord.gg/jgUcbKsgTC",
      label: "Discord",
    },
    {
      icon: "pi pi-globe",
      url: "https://sierravalleyrp.com",
      label: "Website",
    },
  ],
  News: [
    {
      title: "Server Updates",
      date: "2025-01-26",
      description: "New police camera system, updated evidence collection, and performance improvements.",
      badge: "LATEST",
    },
    {
      title: "Welcome to SVRP",
      date: "2025-01-01",
      description: "Sierra Valley Roleplay is now live! Join our community and start your story!",
    },
  ],
  Rules: [
    "Be respectful to all players and staff.",
    "No cheating, exploiting, or metagaming.",
    "Follow staff instructions at all times.",
    "Stay in character - keep OOC to Discord.",
    "Use appropriate language - this is an RP server.",
    "Value your life - realistic RP is required.",
    "Have fun and create great stories!",
  ], 
  Team: [
    { name: "Admin Team", role: "Server Management", avatar: "Wallis.png" },
  ],
  Updates: [
    {
      version: "v1.2.0",
      changes: [
        "Added r14-evidence camera system.",
        "Updated police equipment and vehicles.",
        "Improved server performance.",
        "New loading screen design.",
      ],
    },
    {
      version: "v1.1.0",
      changes: ["Added new businesses.", "Updated inventory system.", "Bug fixes and optimizations."],
    },
  ],

  // Keyboard Configuration - Shows a visual TKL keyboard with key bindings
  // Comment out the entire Keyboard section to hide it
  Keyboard: {
    // Key-value pairs: key name -> what it does
    // Only add important keys you want to highlight
    // Players can hover over highlighted keys to see their function

    // Movement keys
    "W": "Move Forward",
    "A": "Move Left",
    "S": "Move Backward",
    "D": "Move Right",
    "Shift": "Sprint",
    "Ctrl": "Crouch",
    "Space": "Jump",

    // Interaction keys
    "E": "Interact",
    "F": "Enter/Exit Vehicle",
    "T": "Open Chat",
    "Tab": "Inventory",
    "M": "Map",
    "P": "Phone",
    "K": "Menu",

    // Vehicle keys
    "H": "Headlights",
    "L": "Lock/Unlock",
    "G": "Engine",
    "B": "Seatbelt",

    // Combat keys
    "R": "Reload",
    "Q": "Take Cover",

    // Function keys
    "F1": "Help",
    "F2": "Settings",
    "Esc": "Pause Menu",

    // Add more keys as needed...
  },

  // Visual Effects Configuration
  Effects: {
    enabled: true, // Enable visual effects
    // Available effects: "snow", "rain", "leaves", "fireflies", "stars", "bubbles", "confetti", "none"
    type: "fireflies", // Current effect to display
    intensity: "medium", // "light", "medium", "heavy"
    color: "#F97316", // Orange color for effects
  },

  // Typography Configuration
  UI: {
    // Font Configuration
    font: {
      // Primary font for entire UI
      // Built-in options: "Kanit", "Inter", "Roboto", "Open Sans", "Montserrat", "Poppins",
      //                   "Raleway", "Lato", "Bebas Neue", "Playfair Display"
      // Or use any custom font name you load below
      primary: "Kanit",  // Testing custom font as primary

      // Custom Google Fonts URLs (loaded automatically)
      // Add your custom font URL here, then use its name in the primary field above
      // Example: Load "Oswald" font, then set primary: "Oswald"
      customFonts: [
        "https://fonts.googleapis.com/css2?family=Oswald:wght@300;400;500;600;700&display=swap"
      ],
    },

    color: {
      primary: {
        50: "#FAF5FF",
        100: "#F3E8FF",
        200: "#E9D5FF",
        300: "#D8B4FE",
        400: "#C084FC",
        500: "#A855F7",
        600: "#9333EA",
        700: "#7E22CE",
        800: "#6B21A8",
        900: "#581C87",
        950: "#3B0764",
      },
    },
  },
};
