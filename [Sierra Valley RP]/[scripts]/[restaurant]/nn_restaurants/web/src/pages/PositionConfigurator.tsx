import React, { useState, useEffect } from 'react';
import { useVisibility } from '../providers/VisibilityProvider';
import { fetchNui } from '../utils/fetchNui';
import { t } from '../utils/translations';
import { 
  Download, 
  Settings, 
  Trash2, 
  Plus,
  ChefHat,
  Volume2,
  UtensilsCrossed,
  Users,
  Flame,
  Home,
  Move3D,
  Eye,
  EyeOff,
  Coffee,
  Droplets
} from 'lucide-react';

interface Position {
  x: number;
  y: number;
  z: number;
  heading?: number;
  rotation?: { x: number; y: number; z: number };
  type?: string; // For storing machine type
}

interface ConfigCategory {
  id: string;
  name: string;
  icon: React.ReactNode;
  description: string;
  items: ConfigItem[];
}

interface ConfigItem {
  id: string;
  name: string;
  type: 'vector3' | 'vector4' | 'prop_array' | 'complex';
  count: number;
  positions: Position[];
  props?: string[];
}



const PositionConfigurator: React.FC = () => {
  const { visibility } = useVisibility();
  const [restaurantName, setRestaurantName] = useState('');
  const [currentCategory, setCurrentCategory] = useState<string | null>(null);
  const [previewMode, setPreviewMode] = useState(false);
  const [configData, setConfigData] = useState<{ [key: string]: ConfigItem }>({});
  const [generatedConfig, setGeneratedConfig] = useState<string>('');
  const [showConfig, setShowConfig] = useState(false);
  
  // Memoize categories to prevent recreation
  const categories: ConfigCategory[] = React.useMemo(() => [
    {
      id: 'basic',
      name: t('basic_positions'),
      icon: <Home size={20} />,
      description: 'Main restaurant positions and cooking stations',
      items: [
        { id: 'coords', name: t('main_restaurant_coords'), type: 'vector3', count: 1, positions: [] },
        { id: 'cookingStations', name: t('cooking_stations'), type: 'vector3', count: 0, positions: [] },
        { id: 'fridges', name: t('fridges'), type: 'vector3', count: 0, positions: [] },
        { id: 'dumpsters', name: t('dumpsters'), type: 'vector3', count: 0, positions: [] }
      ]
    },
    {
      id: 'audio',
      name: t('audio_system'),
      icon: <Volume2 size={20} />,
      description: 'Speaker positions for restaurant audio',
      items: [
        { id: 'speakers', name: t('speakers'), type: 'vector3', count: 0, positions: [] }
      ]
    },
    {
      id: 'storage',
      name: t('storage_trash'),
      icon: <Trash2 size={20} />,
      description: 'Storage and waste management positions',
      items: [
        {
          id: 'trashCans',
          name: t('trash_cans'),
          type: 'prop_array',
          count: 0,
          positions: [],
          props: ['prop_bin_07d', 'prop_bin_01a', 'prop_bin_05a']
        }
      ]
    },
    {
      id: 'tools',
      name: t('cooking_tools'),
      icon: <UtensilsCrossed size={20} />,
      description: 'Spatulas and cooking equipment',
      items: [
        {
          id: 'spatulas',
          name: t('spatulas'),
          type: 'prop_array',
          count: 0,
          positions: [],
          props: ['sn_spatula']
        }
      ]
    },
    {
      id: 'npc',
      name: t('npc_system'),
      icon: <Users size={20} />,
      description: 'NPC waiting areas and routes',
      items: [
        { id: 'npcWaiting', name: t('npc_waiting_locations'), type: 'vector4', count: 0, positions: [] },
        { id: 'npcRoutes', name: t('npc_routes'), type: 'complex', count: 0, positions: [] }
      ]
    },
    {
      id: 'cooking',
      name: t('cooking_equipment'),
      icon: <ChefHat size={20} />,
      description: 'Fryers and serving plates',
      items: [
        { id: 'fryers', name: t('fryers'), type: 'vector4', count: 0, positions: [] },
        { id: 'friesPlates', name: t('fries_plates'), type: 'complex', count: 0, positions: [] }
      ]
    },
    {
      id: 'grills',
      name: t('grills'),
      icon: <Flame size={20} />,
      description: 'Complex grill configuration with slots and particles',
      items: [
        { id: 'grills', name: t('grills'), type: 'complex', count: 0, positions: [] }
      ]
    },
    {
      id: 'drinks',
      name: 'Drinks Stations',
      icon: <Coffee size={20} />,
      description: 'Drinks machines for soda, juice, and coffee',
      items: [
        { id: 'drinksMachines', name: 'Drinks Machines', type: 'complex', count: 0, positions: [] }
      ]
    }
  ], []);

  // Initialize config data only once, preserving existing data
  useEffect(() => {
    setConfigData(prevData => {
      // Only initialize if no data exists
      if (Object.keys(prevData).length === 0) {
        const initialData: { [key: string]: ConfigItem } = {};
        categories.forEach(category => {
          category.items.forEach(item => {
            initialData[item.id] = { ...item };
          });
        });
        return initialData;
      }
      return prevData;
    });
  }, [categories]);

  // Load saved positions when UI opens
  useEffect(() => {
    if (visibility.visible && visibility.page === 'position-configurator') {
      fetchNui('loadConfigData').then((savedData: any) => {
        if (savedData && Object.keys(savedData).length > 0) {
          // Create default data structure
          const defaultData: { [key: string]: ConfigItem } = {};
          categories.forEach(category => {
            category.items.forEach(item => {
              defaultData[item.id] = { ...item };
            });
          });
          
                     // Merge saved data with default data
           const processedData = { ...defaultData, ...savedData };
           Object.keys(processedData).forEach(key => {
             if (processedData[key]) {
               // Ensure positions array exists
               if (!Array.isArray(processedData[key].positions)) {
                 processedData[key].positions = [];
               }
               // Ensure count exists and is a number
               if (typeof processedData[key].count !== 'number') {
                 processedData[key].count = processedData[key].positions.length;
               }
               // Ensure id exists
               if (!processedData[key].id) {
                 processedData[key].id = key;
               }
               // Ensure name exists
               if (!processedData[key].name) {
                 processedData[key].name = key.replace(/_/g, ' ');
               }
               // Ensure type exists
               if (!processedData[key].type) {
                 processedData[key].type = 'vector3';
               }
             }
           });
           setConfigData(processedData);
        }
      }).catch(() => {
        // Ignore errors, use default data
      });
    }
  }, [visibility]);

  // Listen for config data updates from client
  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.action === 'updateConfigData') {
        const savedData = event.data.data;
        if (savedData && Object.keys(savedData).length > 0) {
          // Create default data structure
          const defaultData: { [key: string]: ConfigItem } = {};
          categories.forEach(category => {
            category.items.forEach(item => {
              defaultData[item.id] = { ...item };
            });
          });
          
          // Merge saved data with default data
          const processedData = { ...defaultData, ...savedData };
          Object.keys(processedData).forEach(key => {
            if (processedData[key]) {
              // Ensure positions array exists
              if (!Array.isArray(processedData[key].positions)) {
                processedData[key].positions = [];
              }
              // Ensure count exists and is a number
              if (typeof processedData[key].count !== 'number') {
                processedData[key].count = processedData[key].positions.length;
              }
              // Ensure id exists
              if (!processedData[key].id) {
                processedData[key].id = key;
              }
              // Ensure name exists
              if (!processedData[key].name) {
                processedData[key].name = key.replace(/_/g, ' ');
              }
              // Ensure type exists
              if (!processedData[key].type) {
                processedData[key].type = 'vector3';
              }
            }
          });
          setConfigData(processedData);
        }
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  const startPositioning = async (itemId: string, index: number) => {
    const item = configData[itemId];
    
    // Handle grill components
    let previewModel = 'prop_mp_cone_02';
    let itemName = itemId;
    
    if (item) {
      itemName = item.name;
      if (item.props && item.props.length > 0) {
        previewModel = item.props[0];
      }
    }
    
    // Set specific models for different item types
    const previewProps = {
      cookingStations: 'prop_cooker_03',
      fridges: 'prop_fridge_03',
      speakers: 'prop_speaker_05',
      trashCans: 'prop_bin_07d',
      spatulas: 'sn_spatula',
      fryers: 'sn_fryer',
      dumpsters: 'prop_dumpster_01a',
      grills: 'prop_bbq_3',
      friesPlates: 'prop_food_tray_01'
    };
    
    // Check if it's a grill component
    if (itemId.startsWith('grill_')) {
      if (itemId.includes('particleCoords')) {
        previewModel = 'sn_burgerpattyraw'; // Use the actual prop model from Config.MeatModels
      } else if (itemId.includes('slot')) {
        // For meat slots, use the raw meat model with gizmo
        previewModel = 'sn_burgerpattyraw';
      } else if (itemId.includes('intCoords')) {
        previewModel = 'prop_mp_cone_02'; // Interaction coords use marker
      } else {
        previewModel = 'prop_mp_cone_02'; // Default for other grill components
      }
    } else {
      // Use standard preview props
      previewModel = previewProps[itemId as keyof typeof previewProps] || 'prop_mp_cone_02';
    }

    // Close UI and start positioning mode
    await fetchNui('startPositioning', {
      itemId,
      index,
      itemName: itemName,
      previewModel: previewModel
    });
    
    // Close the UI
    await fetchNui('hideFrame', {});
  };

  // Position saving is now handled by the client-side via commands
  // The UI will be updated when the configurator is reopened

  const addNewPosition = (itemId: string) => {
    const item = configData[itemId];
    
    // Ensure item exists and has proper structure
    if (!item) {
      console.error(`Item ${itemId} not found in configData`);
      return;
    }
    
    if (typeof item.count !== 'number') {
      item.count = item.positions?.length || 0;
    }
    
    const nextIndex = item.count; // Use the current count as the next index
    
    // Start positioning for the new position (don't add to array yet)
    startPositioning(itemId, nextIndex);
  };

  const removePosition = (itemId: string, index: number) => {
    const newConfigData = { ...configData };
    const item = newConfigData[itemId];
    
    // Ensure item exists and has proper structure
    if (!item) {
      console.error(`Item ${itemId} not found in configData`);
      return;
    }
    
    if (!Array.isArray(item.positions)) {
      item.positions = [];
    }
    
    if (index >= 0 && index < item.positions.length) {
      item.positions.splice(index, 1);
      item.count = item.positions.length;
    }
    
    setConfigData(newConfigData);
  };

  const generateConfig = () => {
    const config = generateConfigCode();
    setGeneratedConfig(config);
    setShowConfig(true);
  };

  const generateConfigCode = (): string => {
    const lines = [`    ['${restaurantName}'] = {`];
    
    // Add Enabled field (default to true)
    lines.push('        Enabled = true,');
    
    // Main coords
    const coords = configData.coords?.positions[0];
    if (coords) {
      lines.push(`        coords = vector3(${coords.x.toFixed(2)}, ${coords.y.toFixed(2)}, ${coords.z.toFixed(2)}),`);
    }
    
    // Cooking stations
    if (configData.cookingStations?.count > 0) {
      lines.push('        CookingStations = {');
      configData.cookingStations.positions.forEach(pos => {
        lines.push('            {');
        lines.push(`                coords = vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}),`);
        lines.push('            },');
      });
      lines.push('        },');
    }
    
    // Speakers
    if (configData.speakers?.count > 0) {
      lines.push('        Speakers = {');
      configData.speakers.positions.forEach(pos => {
        lines.push(`            vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}),`);
      });
      lines.push('        },');
    }
    
    // Fridges
    if (configData.fridges?.count > 0) {
      lines.push('        Fridges = {');
      configData.fridges.positions.forEach(pos => {
        lines.push(`            vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}),`);
      });
      lines.push('        },');
    }
    
    // Trash cans
    if (configData.trashCans?.count > 0) {
      lines.push('        TrashCans = {');
      configData.trashCans.positions.forEach(pos => {
        lines.push('            {');
        lines.push("                prop = 'prop_bin_07d',");
        lines.push(`                coords = vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}),`);
        if (pos.rotation) {
          lines.push(`                rotation = vector3(${pos.rotation.x.toFixed(2)}, ${pos.rotation.y.toFixed(2)}, ${pos.rotation.z.toFixed(2)}),`);
        } else {
          lines.push('                rotation = vector3(0.0, 0.0, 0.0),');
        }
        lines.push('                limit = 20');
        lines.push('            },');
      });
      lines.push('        },');
    }
    
    // Dumpsters
    if (configData.dumpsters?.count > 0) {
      lines.push('        Dumpsters = {');
      configData.dumpsters.positions.forEach(pos => {
        lines.push(`            vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}),`);
      });
      lines.push('        },');
    }
    
    // Spatulas
    if (configData.spatulas?.count > 0) {
      lines.push('        Spatulas = {');
      lines.push("            prop = 'sn_spatula',");
      lines.push('            objects = {');
      configData.spatulas.positions.forEach(pos => {
        lines.push('                {');
        lines.push(`                    coords = vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}),`);
        if (pos.rotation) {
          lines.push(`                    rotation = vector3(${pos.rotation.x.toFixed(2)}, ${pos.rotation.y.toFixed(2)}, ${pos.rotation.z.toFixed(2)})`);
        } else {
          lines.push('                    rotation = vector3(0.0, 0.0, 0.0)');
        }
        lines.push('                },');
      });
      lines.push('            }');
      lines.push('        },');
    }
    
    // NPC waiting locations
    if (configData.npcWaiting?.count > 0) {
      lines.push('        NpcWaitingLocations = {');
      configData.npcWaiting.positions.forEach((pos, index) => {
        const heading = pos.heading || 0.0;
        lines.push(`            [${index + 1}] = vector4(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}, ${heading.toFixed(2)}),`);
      });
      lines.push('        },');
    }
    
    // Fryers
    if (configData.fryers?.count > 0) {
      lines.push('        Fryers = {');
      lines.push("            prop = 'sn_fryer',");
      lines.push('            particle = {');
      lines.push("                dict = 'core',");
      lines.push("                anim = 'ent_amb_foundry_heat_haze',");
      lines.push('                looped = true,');
      lines.push('                scale = 0.3,');
      lines.push('                alpha = 5.0,');
      lines.push('                duration = 15000,');
      lines.push('                offset = vector3(0.0, 0.0, 0.4),');
      lines.push('                rotation = vector3(0.0, 0.0, 0.0)');
      lines.push('            },');
      lines.push('            coords = {');
      configData.fryers.positions.forEach(pos => {
        const heading = pos.heading || 0.0;
        lines.push(`                vector4(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}, ${heading.toFixed(2)}),`);
      });
      lines.push('            }');
      lines.push('        },');
    }
    
    // Fries Plates
    if (configData.friesPlates?.count > 0) {
      lines.push('        FriesPlates = {');
      lines.push("            prop = 'prop_food_tray_01',");
      lines.push('            plates = {');
      configData.friesPlates.positions.forEach((pos, index) => {
        lines.push('                {');
        // Plate Coords
        lines.push('                    plateCoords = {');
        lines.push(`                        coords = vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}),`);
        if (pos.rotation) {
          lines.push(`                        rotation = vector3(${pos.rotation.x.toFixed(2)}, ${pos.rotation.y.toFixed(2)}, ${pos.rotation.z.toFixed(2)})`);
        } else {
          lines.push('                        rotation = vector3(0.0, 0.0, 0.0)');
        }
        lines.push('                    },');
        // Fries Coords
        lines.push('                    friesCoords = {');
        lines.push("                        ['frenchfries'] = {");
        lines.push(`                            coords = vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${(pos.z - 0.11).toFixed(2)}),`);
        if (pos.rotation) {
          lines.push(`                            rotation = vector3(${pos.rotation.x.toFixed(2)}, ${pos.rotation.y.toFixed(2)}, ${pos.rotation.z.toFixed(2)})`);
        } else {
          lines.push('                            rotation = vector3(90.0, 0.0, 0.0)');
        }
        lines.push('                        },');
        lines.push("                        ['chicken_nuggets'] = {");
        lines.push(`                            coords = vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${(pos.z + 0.34).toFixed(2)}),`);
        if (pos.rotation) {
          lines.push(`                            rotation = vector3(${pos.rotation.x.toFixed(2)}, ${pos.rotation.y.toFixed(2)}, ${pos.rotation.z.toFixed(2)})`);
        } else {
          lines.push('                            rotation = vector3(0.0, 0.0, 0.0)');
        }
        lines.push('                        }');
        lines.push('                    },');
        // Meat Coords
        lines.push('                    meatCoords = {');
        lines.push("                        ['rawburgerpatty'] = {");
        lines.push(`                            coords = vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${(pos.z - 0.14).toFixed(2)}),`);
        if (pos.rotation) {
          lines.push(`                            rotation = vector3(${pos.rotation.x.toFixed(2)}, ${pos.rotation.y.toFixed(2)}, ${pos.rotation.z.toFixed(2)})`);
        } else {
          lines.push('                            rotation = vector3(90.0, 0.0, 0.0)');
        }
        lines.push('                        }');
        lines.push('                    }');
        lines.push('                },');
      });
      lines.push('            }');
      lines.push('        },');
    }
    
    // Grills - Fixed implementation with proper data persistence
    const grillKeys = Object.keys(configData).filter(key => key.startsWith('grill_'));
    if (grillKeys.length > 0) {
      lines.push('        Grills = {');
      
      // Process each grill component
      const grillsByIndex: { [key: number]: any } = {};
      
      grillKeys.forEach(key => {
        const parts = key.split('_');
        if (parts.length < 3) return;
        
        const grillIndex = parseInt(parts[1]);
        if (isNaN(grillIndex)) return;
        
        if (!grillsByIndex[grillIndex]) {
          grillsByIndex[grillIndex] = {
            intCoords: null,
            particleCoords: null,
            meatSlots: {}
          };
        }
        
        const item = configData[key];
        if (!item?.positions?.length) return;
        
        const position = item.positions[0];
        
        // Handle different component types
        if (parts[2] === 'intCoords') {
          grillsByIndex[grillIndex].intCoords = position;
        } else if (parts[2] === 'particleCoords') {
          grillsByIndex[grillIndex].particleCoords = position;
        } else if (parts[3] === 'slot') {
          const meatType = parts[2];
          const slotIndex = parseInt(parts[4]);
          
          if (!grillsByIndex[grillIndex].meatSlots[meatType]) {
            grillsByIndex[grillIndex].meatSlots[meatType] = {};
          }
          
          grillsByIndex[grillIndex].meatSlots[meatType][slotIndex + 1] = position;
        }
      });
      
      // Generate config for each grill
      Object.keys(grillsByIndex).forEach(grillIndexStr => {
        const grillIndex = parseInt(grillIndexStr);
        const grill = grillsByIndex[grillIndex];
        
        lines.push(`            [${grillIndex + 1}] = {`);
        
        // Add intCoords if available
        if (grill.intCoords) {
          lines.push(`                intCoords = vector3(${grill.intCoords.x.toFixed(2)}, ${grill.intCoords.y.toFixed(2)}, ${grill.intCoords.z.toFixed(2)}),`);
        }
        
        // Add particleCoords if available
        if (grill.particleCoords) {
          lines.push(`                particleCoords = vector3(${grill.particleCoords.x.toFixed(2)}, ${grill.particleCoords.y.toFixed(2)}, ${grill.particleCoords.z.toFixed(2)}),`);
        }
        
        // ALWAYS add particle configuration (default)
        lines.push('                particle = {');
        lines.push("                    dict = 'core',");
        lines.push("                    anim = 'ent_anim_bbq',");
        lines.push('                    looped = true,');
        lines.push('                    scale = 1.0,');
        lines.push('                    alpha = 0.8,');
        lines.push('                    duration = 10000,');
        lines.push('                    offset = vector3(0.0, 0.0, -0.5),');
        lines.push('                    rotation = vector3(0.0, 0.0, 0.0)');
        lines.push('                },');
        
        // Grill coordinates (meat slots)
        if (Object.keys(grill.meatSlots).length > 0) {
          lines.push('                grillCoords = {');
          Object.keys(grill.meatSlots).forEach(meatType => {
            const meatSlots = grill.meatSlots[meatType];
            lines.push(`                    ['${meatType}'] = {`);
            
            // Output all slots for this meat type
            Object.keys(meatSlots).forEach(slotIndex => {
              const pos = meatSlots[slotIndex];
              lines.push(`                        [${slotIndex}] = {`);
              lines.push(`                            coords = vector3(${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}),`);
              if (pos.rotation) {
                lines.push(`                            rotation = vector3(${pos.rotation.x.toFixed(2)}, ${pos.rotation.y.toFixed(2)}, ${pos.rotation.z.toFixed(2)})`);
              } else {
                lines.push('                            rotation = vector3(0.0, 0.0, 0.0)');
              }
              lines.push('                        },');
            });
            
            lines.push('                    },');
          });
          lines.push('                },');
        }
        
        lines.push('            },');
      });
      
      lines.push('        },');
    }
    
    // Drinks Machines
    const drinksMachineKeys = Object.keys(configData).filter(key => key.startsWith('drinks_machine_'));
    if (drinksMachineKeys.length > 0) {
      lines.push('        DrinksMachines = {');
      
      // Process each drinks machine component
      const machinesByIndex: { [key: number]: any } = {};
      
      drinksMachineKeys.forEach(key => {
        const parts = key.split('_');
        if (parts.length < 4) return;
        
        const machineIndex = parseInt(parts[2]);
        if (isNaN(machineIndex)) return;
        
        if (!machinesByIndex[machineIndex]) {
          machinesByIndex[machineIndex] = {
            coords: null,
            intCoords: null,
            type: 'soda_juice' // Default type
          };
        }
        
        // Check for machine type
        const typeKey = `drinks_machine_${machineIndex}_type`;
        if (configData[typeKey]?.positions?.[0]?.type) {
          machinesByIndex[machineIndex].type = configData[typeKey].positions[0].type;
        }
        
        const item = configData[key];
        if (!item?.positions?.length) return;
        
        const position = item.positions[0];
        
        // Handle different component types
        if (parts[3] === 'coords') {
          machinesByIndex[machineIndex].coords = position;
        } else if (parts[3] === 'intCoords') {
          machinesByIndex[machineIndex].intCoords = position;
        }
      });
      
      // Generate config for each drinks machine
      Object.keys(machinesByIndex).forEach(machineIndexStr => {
        const machineIndex = parseInt(machineIndexStr);
        const machine = machinesByIndex[machineIndex];
        
        lines.push(`            [${machineIndex + 1}] = {`);
        
        // Add coords if available
        if (machine.coords) {
          lines.push(`                coords = vector3(${machine.coords.x.toFixed(2)}, ${machine.coords.y.toFixed(2)}, ${machine.coords.z.toFixed(2)}),`);
        }
        
        // Add intCoords if available
        if (machine.intCoords) {
          lines.push(`                intCoords = vector3(${machine.intCoords.x.toFixed(2)}, ${machine.intCoords.y.toFixed(2)}, ${machine.intCoords.z.toFixed(2)}),`);
        }
        
        // Add machine type (default to soda_juice)
        lines.push(`                type = '${machine.type}',`);
        
        lines.push('            },');
      });
      
      lines.push('        },');
    }
    
    // Add NPC settings and other defaults
    lines.push('        NpcEnabled = true,');
    lines.push('        NpcModels = {');
    lines.push("            'a_f_m_business_02',");
    lines.push("            'a_f_y_eastsa_03',");
    lines.push("            'a_f_o_ktown_01',");
    lines.push("            'a_m_m_bevhills_01',");
    lines.push("            'a_m_m_business_01',");
    lines.push("            'a_m_m_fatlatin_01',");
    lines.push("            'a_m_m_genfat_02',");
    lines.push('        },');
    lines.push('        NpcInterval = 60000,');
    
    lines.push('    },');
    
    return lines.join('\n');
  };

  const togglePreview = async () => {
    setPreviewMode(!previewMode);
    await fetchNui('togglePreview', { enabled: !previewMode, configData });
  };

  if (!visibility.visible || visibility.page !== 'position-configurator') return null;

  return (
    <div className="h-screen bg-gray-900 text-white flex flex-col">
      {/* Header */}
      <div className="bg-gray-800 p-6 border-b border-gray-700">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-2xl font-bold text-white flex items-center gap-3">
            <Settings className="text-blue-400" size={28} />
            Restaurant Position Configurator
          </h1>
          <button
            onClick={() => fetchNui('hideFrame', {})}
            className="text-gray-400 hover:text-white transition-colors"
          >
            ✕
          </button>
        </div>
        
        <div className="flex items-center gap-4">
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-300 mb-2">{t('restaurant_name')}</label>
            <input
              type="text"
              value={restaurantName}
              onChange={(e) => setRestaurantName(e.target.value)}
              placeholder={t('enter_restaurant_name')}
              className="w-full px-4 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white placeholder-gray-400 focus:border-blue-500 focus:outline-none"
            />
          </div>
          
          <div className="flex gap-2">
            <button
              onClick={togglePreview}
              className={`px-4 py-2 rounded-lg flex items-center gap-2 transition-colors ${
                previewMode 
                  ? 'bg-green-600 hover:bg-green-700 text-white' 
                  : 'bg-gray-700 hover:bg-gray-600 text-gray-300'
              }`}
            >
              {previewMode ? <Eye size={16} /> : <EyeOff size={16} />}
                              {previewMode ? t('hide_preview') : t('show_preview')}
            </button>
            
            <button
              onClick={generateConfig}
              disabled={!restaurantName}
              className="px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 disabled:cursor-not-allowed text-white rounded-lg flex items-center gap-2 transition-colors"
            >
              <Download size={16} />
                              {t('generate_config')}
            </button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex">
        {/* Categories Sidebar */}
        <div className="w-80 bg-gray-800 border-r border-gray-700 p-4 overflow-y-auto">
          <h2 className="text-lg font-semibold mb-4 text-white">Configuration Categories</h2>
          
          {categories.map(category => (
            <div key={category.id} className="mb-4">
              <button
                onClick={() => setCurrentCategory(currentCategory === category.id ? null : category.id)}
                className={`w-full p-3 rounded-lg border transition-all duration-200 ${
                  currentCategory === category.id
                    ? 'bg-blue-600 border-blue-500 text-white'
                    : 'bg-gray-700 border-gray-600 text-gray-300 hover:bg-gray-600'
                }`}
              >
                <div className="flex items-center gap-3">
                  {category.icon}
                  <div className="text-left flex-1">
                    <div className="font-medium">{category.name}</div>
                    <div className="text-xs opacity-70">{category.description}</div>
                  </div>
                </div>
              </button>
              
              {currentCategory === category.id && (
                <div className="mt-2 space-y-2 pl-4">
                  {category.items.map(item => (
                    <div key={item.id} className="bg-gray-900 rounded-lg p-3 border border-gray-600">
                      <div className="flex items-center justify-between mb-2">
                        <span className="font-medium text-white">{item.name}</span>
                        <span className="text-xs text-blue-400 bg-blue-400/20 px-2 py-1 rounded">
                          {configData[item.id]?.count || 0} configured
                        </span>
                      </div>
                      
                      {/* Position List */}
                      {Array.isArray(configData[item.id]?.positions) && configData[item.id].positions.map((pos, index) => (
                        <div key={index} className="flex items-center gap-2 mb-2 text-sm">
                          <span className="text-gray-400">#{index + 1}</span>
                          <span className="text-gray-300 flex-1">
                            {pos.x.toFixed(1)}, {pos.y.toFixed(1)}, {pos.z.toFixed(1)}
                          </span>
                          <button
                            onClick={() => startPositioning(item.id, index)}
                            className="text-blue-400 hover:text-blue-300"
                            title="Edit position"
                          >
                            <Move3D size={14} />
                          </button>
                          <button
                            onClick={() => removePosition(item.id, index)}
                            className="text-red-400 hover:text-red-300"
                            title="Remove position"
                          >
                            <Trash2 size={14} />
                          </button>
                        </div>
                      ))}
                      
                      {currentCategory !== 'grills' && (
                        <button
                          onClick={() => addNewPosition(item.id)}
                          className="w-full mt-2 p-2 border-2 border-dashed border-blue-500/30 rounded-lg text-blue-400 hover:border-blue-500/50 hover:bg-blue-500/5 transition-colors flex items-center justify-center gap-2"
                        >
                          <Plus size={16} />
                          Add Position
                        </button>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Main Content Area */}
        <div className="flex-1 p-6 bg-gray-900">
          {showConfig ? (
            <div className="h-full flex flex-col">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-semibold text-white">Generated Configuration</h3>
                <div className="flex gap-2">
                  <button
                    onClick={() => setShowConfig(false)}
                    className="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-lg transition-colors"
                  >
                    Back
                  </button>
                </div>
              </div>
              <div className="flex-1 bg-gray-800 rounded-lg p-4 border border-gray-700 overflow-auto">
                <pre className="text-sm text-gray-300 whitespace-pre-wrap font-mono">
                  {generatedConfig}
                </pre>
              </div>
            </div>
          ) : currentCategory === 'grills' ? (
            <GrillConfiguration 
              configData={configData} 
              onUpdateConfig={setConfigData}
              onStartPositioning={startPositioning}
            />
          ) : currentCategory === 'drinks' ? (
            <DrinksMachineConfiguration 
              configData={configData} 
              onUpdateConfig={setConfigData}
              onStartPositioning={startPositioning}
            />
          ) : (
            <div className="text-center py-12">
              <Settings size={64} className="text-gray-600 mx-auto mb-4" />
              <h3 className="text-xl font-semibold text-gray-400 mb-2">
                {t('position_configurator')}
              </h3>
                             <div className="space-y-3 text-gray-500 max-w-md mx-auto">
                 <p>Select a category and click "Add Position" to start positioning</p>
                 <p>When positioning mode starts, the UI will close automatically</p>
                 <p>The UI will automatically reopen after saving or cancelling</p>
                                 <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
                   <h4 className="font-medium text-blue-400 mb-2">Positioning Controls:</h4>
                   <ul className="text-sm text-left space-y-1">
                     <li><code className="bg-gray-700 px-2 py-1 rounded">ENTER</code> - Save current position (marker mode)</li>
                     <li><code className="bg-gray-700 px-2 py-1 rounded">E</code> - Confirm object placement</li>
                     <li><code className="bg-gray-700 px-2 py-1 rounded">LEFT/RIGHT ARROWS</code> - Rotate object</li>
                     <li><code className="bg-gray-700 px-2 py-1 rounded">ESC</code> - Cancel positioning</li>
                     <li><code className="bg-gray-700 px-2 py-1 rounded">/position-config</code> - Reopen this UI</li>
                   </ul>
                 </div>
              </div>
            </div>
          )}
        </div>
      </div>
      
      {/* Status Bar */}
      <div className="bg-gray-800 p-3 border-t border-gray-700 flex items-center justify-between text-sm">
        <div className="flex items-center gap-4 text-gray-400">
          <span>Total positions configured: {Object.values(configData).reduce((sum, item) => sum + item.count, 0)}</span>
          {previewMode && (
            <span className="text-green-400 flex items-center gap-1">
              <Eye size={14} />
              Preview active
            </span>
          )}
        </div>
        
        <div className="text-gray-500">
          Restaurant Position Configurator v1.0
        </div>
      </div>
    </div>
  );
};

// Grill Configuration Component
interface GrillConfigurationProps {
  configData: { [key: string]: ConfigItem };
  onUpdateConfig: (config: { [key: string]: ConfigItem }) => void;
  onStartPositioning: (itemId: string, index: number) => Promise<void>;
}

const GrillConfiguration: React.FC<GrillConfigurationProps> = ({ 
  configData, 
  onUpdateConfig, 
  onStartPositioning 
}) => {
  const [selectedGrill, setSelectedGrill] = useState<number>(0);
  const [selectedMeatType, setSelectedMeatType] = useState<string>('rawburgerpatty');
  
  const meatTypes = ['rawburgerpatty']; // Add more meat types as needed
  
  // Auto-create grills when grill components are found or when grills entry exists
  useEffect(() => {
    const grillComponents = Object.keys(configData).filter(key => key.startsWith('grill_'));
    const grillNumbers = new Set<number>();
    
    // Get grill numbers from existing components
    grillComponents.forEach(key => {
      const match = key.match(/grill_.*_(\d+)/);
      if (match) {
        grillNumbers.add(parseInt(match[1]));
      }
    });
    
    // Check if we need to create or update the grills entry
    const maxGrillNumber = grillNumbers.size > 0 ? Math.max(...Array.from(grillNumbers)) : -1;
    const currentGrillCount = configData.grills?.count || 0;
    const requiredGrillCount = Math.max(maxGrillNumber + 1, currentGrillCount);
    
    if (requiredGrillCount > 0 && (!configData.grills || configData.grills.count !== requiredGrillCount)) {
      const newConfig = { ...configData };
      if (!newConfig.grills) {
        newConfig.grills = { 
          id: 'grills', 
          name: 'Grills', 
          type: 'complex', 
          count: 0, 
          positions: [] 
        };
      }
      newConfig.grills.count = requiredGrillCount;
      onUpdateConfig(newConfig);
    }
  }, [configData, onUpdateConfig]);
  
  const addGrill = () => {
    const newConfig = { ...configData };
    if (!newConfig.grills) {
      newConfig.grills = { 
        id: 'grills', 
        name: 'Grills', 
        type: 'complex', 
        count: 0, 
        positions: [] 
      };
    }
    newConfig.grills.count += 1;
    onUpdateConfig(newConfig);
  };
  
  const removeGrill = (grillIndex: number) => {
    const newConfig = { ...configData };
    
    // Remove the grill count
    if (newConfig.grills) {
      newConfig.grills.count = Math.max(0, newConfig.grills.count - 1);
    }
    
    // Remove all grill components for this index
    Object.keys(newConfig).forEach(key => {
      if (key.startsWith(`grill_${grillIndex}_`)) {
        delete newConfig[key];
      }
    });
    
    // If no grills left, remove the grills entry
    if (newConfig.grills && newConfig.grills.count === 0) {
      delete newConfig.grills;
    }
    
    onUpdateConfig(newConfig);
    
    // Reset selected grill if it was the one being removed
    if (selectedGrill >= newConfig.grills?.count || 0) {
      setSelectedGrill(Math.max(0, (newConfig.grills?.count || 0) - 1));
    }
  };
  
  const addGrillComponent = (componentType: string, grillIndex: number) => {
    const newConfig = { ...configData };
    if (!newConfig.grills) {
      newConfig.grills = { 
        id: 'grills', 
        name: 'Grills', 
        type: 'complex', 
        count: 0, 
        positions: [] 
      };
    }
    
    // Add component position
    const componentId = `grill_${componentType}_${grillIndex}`;
    if (!newConfig[componentId]) {
      newConfig[componentId] = { 
        id: componentId, 
        name: `${componentType} for Grill ${grillIndex + 1}`, 
        type: 'vector3', 
        count: 0, 
        positions: [] 
      };
    }
    newConfig[componentId].count += 1;
    onUpdateConfig(newConfig);
  };
  
  const addMeatSlot = (grillIndex: number, meatType: string, slotIndex: number) => {
    const newConfig = { ...configData };
    const slotId = `grill_${grillIndex}_${meatType}_slot_${slotIndex}`;
    if (!newConfig[slotId]) {
      newConfig[slotId] = { 
        id: slotId, 
        name: `${meatType} Slot ${slotIndex + 1} for Grill ${grillIndex + 1}`, 
        type: 'vector3', 
        count: 0, 
        positions: [] 
      };
    }
    newConfig[slotId].count += 1;
    onUpdateConfig(newConfig);
  };
  
  const startPositioning = (itemId: string, index: number) => {
    // Ensure the item exists in configData before positioning
    if (!configData[itemId]) {
      const newConfig = { ...configData };
      newConfig[itemId] = {
        id: itemId,
        name: itemId.replace(/_/g, ' '),
        type: 'vector3',
        count: 0,
        positions: []
      };
      onUpdateConfig(newConfig);
    }
    onStartPositioning(itemId, index);
  };
  
  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-xl font-semibold text-white">Grill Configuration</h3>
        <button
          onClick={addGrill}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg flex items-center gap-2 transition-colors"
        >
          <Plus size={16} />
          Add Grill
        </button>
      </div>
      
      <div className="flex gap-6 h-full">
        {/* Grill List */}
        <div className="w-1/3 bg-gray-800 rounded-lg p-4 border border-gray-700">
          <h4 className="text-lg font-medium text-white mb-4">Grills</h4>
          <div className="space-y-2">
            {Array.from({ length: configData.grills?.count || 0 }, (_, i) => (
              <div key={i} className="flex gap-2">
                <button
                  onClick={() => setSelectedGrill(i)}
                  className={`flex-1 p-3 rounded-lg border transition-all ${
                    selectedGrill === i
                      ? 'bg-blue-600 border-blue-500 text-white'
                      : 'bg-gray-700 border-gray-600 text-gray-300 hover:bg-gray-600'
                  }`}
                >
                  Grill #{i + 1}
                </button>
                <button
                  onClick={() => removeGrill(i)}
                  className="px-3 py-3 bg-red-600 hover:bg-red-700 text-white rounded-lg transition-colors"
                  title="Remove grill"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            ))}
          </div>
          {/* Debug info */}
          <div className="mt-4 p-2 bg-gray-700 rounded text-xs text-gray-400">
            <div>Grills count: {configData.grills?.count || 0}</div>
            <div>Total config items: {Object.keys(configData).length}</div>
            <div>Grill items: {Object.keys(configData).filter(k => k.startsWith('grill_')).length}</div>
          </div>
        </div>
        
        {/* Grill Configuration */}
        <div className="flex-1 bg-gray-800 rounded-lg p-4 border border-gray-700">
          {selectedGrill < (configData.grills?.count || 0) ? (
            <div>
              <h4 className="text-lg font-medium text-white mb-4">
                Grill #{selectedGrill + 1} Configuration
              </h4>
              
                            <div className="space-y-6">
                {/* Basic Grill Components */}
                <div>
                  <h5 className="text-md font-medium text-gray-300 mb-3">Basic Components</h5>
                  <div className="grid grid-cols-2 gap-3">
                    <button
                      onClick={() => startPositioning(`grill_${selectedGrill}_intCoords`, 0)}
                      className="p-3 bg-gray-700 hover:bg-gray-600 rounded-lg border border-gray-600 text-gray-300 transition-colors"
                    >
                      <div className="text-sm font-medium">Interaction Coords</div>
                      <div className="text-xs text-gray-400">Where players interact</div>
                      {configData[`grill_${selectedGrill}_intCoords`]?.positions?.length > 0 && (
                        <div className="text-xs text-green-400 mt-1">✓ Positioned</div>
                      )}
                    </button>
                    <button
                      onClick={() => startPositioning(`grill_${selectedGrill}_particleCoords`, 0)}
                      className="p-3 bg-gray-700 hover:bg-gray-600 rounded-lg border border-gray-600 text-gray-300 transition-colors"
                    >
                      <div className="text-sm font-medium">Particle Coords</div>
                      <div className="text-xs text-gray-400">Smoke/fire effects</div>
                      {configData[`grill_${selectedGrill}_particleCoords`]?.positions?.length > 0 && (
                        <div className="text-xs text-green-400 mt-1">✓ Positioned</div>
                      )}
                    </button>
                  </div>
                </div>
                
                {/* Meat Slots */}
                <div>
                  <h5 className="text-md font-medium text-gray-300 mb-3">Meat Slots</h5>
                  <div className="mb-3">
                    <select
                      value={selectedMeatType}
                      onChange={(e) => setSelectedMeatType(e.target.value)}
                      className="px-3 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white"
                    >
                      {meatTypes.map(type => (
                        <option key={type} value={type}>{type}</option>
                      ))}
                    </select>
                  </div>
                  <div className="grid grid-cols-5 gap-2">
                    {Array.from({ length: 10 }, (_, i) => {
                      const slotId = `grill_${selectedGrill}_${selectedMeatType}_slot_${i}`;
                      const hasPosition = configData[slotId]?.positions?.length > 0;
                      return (
                        <button
                          key={i}
                          onClick={() => startPositioning(slotId, 0)}
                          className={`p-2 rounded border text-sm transition-colors ${
                            hasPosition
                              ? 'bg-green-600/20 border-green-500 text-green-400 hover:bg-green-600/30'
                              : 'bg-gray-700 hover:bg-gray-600 border-gray-600 text-gray-300'
                          }`}
                        >
                          <div>Slot {i + 1}</div>
                          {hasPosition && (
                            <div className="text-xs text-green-300">✓ Set</div>
                          )}
                        </button>
                      );
                    })}
                  </div>
                </div>
                
                {/* Position List */}
                <div>
                  <h5 className="text-md font-medium text-gray-300 mb-3">Configured Positions</h5>
                  <div className="space-y-2 max-h-40 overflow-y-auto">
                    {Object.keys(configData).map(key => {
                      if (key.startsWith(`grill_${selectedGrill}`)) {
                        const item = configData[key];
                        // Format the display name for better readability
                        let displayName = key;
                        if (key.includes('intCoords')) {
                          displayName = 'Interaction Coords';
                        } else if (key.includes('particleCoords')) {
                          displayName = 'Particle Coords';
                        } else if (key.includes('slot')) {
                          const parts = key.split('_');
                          const meatType = parts[2];
                          const slotIndex = parts[4];
                          displayName = `${meatType} Slot ${parseInt(slotIndex) + 1}`;
                        }
                        
                        return (
                          <div key={key} className="bg-gray-700 rounded-lg p-3 border border-gray-600">
                            <div className="flex items-center justify-between mb-2">
                              <span className="font-medium text-white">{displayName}</span>
                              <span className="text-xs text-blue-400 bg-blue-400/20 px-2 py-1 rounded">
                                {item.count} configured
                              </span>
                            </div>
                            {item.positions.map((pos, index) => (
                              <div key={index} className="flex items-center gap-2 mb-2 text-sm">
                                <span className="text-gray-400">#{index + 1}</span>
                                <span className="text-gray-300 flex-1">
                                  {pos.x.toFixed(1)}, {pos.y.toFixed(1)}, {pos.z.toFixed(1)}
                                </span>
                                <button
                                  onClick={() => startPositioning(key, index)}
                                  className="text-blue-400 hover:text-blue-300"
                                  title="Edit position"
                                >
                                  <Move3D size={14} />
                                </button>
                              </div>
                            ))}
                            <button
                              onClick={() => startPositioning(key, item.count)}
                              className="w-full mt-2 p-2 border-2 border-dashed border-blue-500/30 rounded-lg text-blue-400 hover:border-blue-500/50 hover:bg-blue-500/5 transition-colors flex items-center justify-center gap-2"
                            >
                              <Plus size={16} />
                              Add Position
                            </button>
                          </div>
                        );
                      }
                      return null;
                    })}
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="text-center py-12 text-gray-400">
              <Flame size={48} className="mx-auto mb-4 text-gray-600" />
              <p>No grills configured yet.</p>
              <p className="text-sm">Click "Add Grill" to get started.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

// Drinks Machine Configuration Component
interface DrinksMachineConfigurationProps {
  configData: { [key: string]: ConfigItem };
  onUpdateConfig: (config: { [key: string]: ConfigItem }) => void;
  onStartPositioning: (itemId: string, index: number) => Promise<void>;
}

const DrinksMachineConfiguration: React.FC<DrinksMachineConfigurationProps> = ({ 
  configData, 
  onUpdateConfig, 
  onStartPositioning 
}) => {
  const [selectedMachine, setSelectedMachine] = useState<number>(0);
  const [selectedMachineType, setSelectedMachineType] = useState<string>('soda_juice');
  
  // Load machine type from config when machine is selected
  useEffect(() => {
    const machineTypeKey = `drinks_machine_${selectedMachine}_type`;
    const savedType = configData[machineTypeKey]?.positions?.[0]?.type || 'soda_juice';
    setSelectedMachineType(savedType);
  }, [selectedMachine, configData]);
  
  const machineTypes = [
    { id: 'soda_juice', name: 'Soda & Juice Machine', icon: <Droplets size={16} /> },
    { id: 'coffee', name: 'Coffee Machine', icon: <Coffee size={16} /> }
  ];
  
  // Auto-create drinks machines when machine components are found or when drinksMachines entry exists
  useEffect(() => {
    const machineComponents = Object.keys(configData).filter(key => key.startsWith('drinks_machine_'));
    const machineNumbers = new Set<number>();
    
    // Get machine numbers from existing components
    machineComponents.forEach(key => {
      const match = key.match(/drinks_machine_.*_(\d+)/);
      if (match) {
        machineNumbers.add(parseInt(match[1]));
      }
    });
    
    // Check if we need to create or update the drinksMachines entry
    const maxMachineNumber = machineNumbers.size > 0 ? Math.max(...Array.from(machineNumbers)) : -1;
    const currentMachineCount = configData.drinksMachines?.count || 0;
    const requiredMachineCount = Math.max(maxMachineNumber + 1, currentMachineCount);
    
    if (requiredMachineCount > 0 && (!configData.drinksMachines || configData.drinksMachines.count !== requiredMachineCount)) {
      const newConfig = { ...configData };
      if (!newConfig.drinksMachines) {
        newConfig.drinksMachines = { 
          id: 'drinksMachines', 
          name: 'Drinks Machines', 
          type: 'complex', 
          count: 0, 
          positions: [] 
        };
      }
      newConfig.drinksMachines.count = requiredMachineCount;
      onUpdateConfig(newConfig);
    }
  }, [configData, onUpdateConfig]);
  
  const addMachine = () => {
    const newConfig = { ...configData };
    if (!newConfig.drinksMachines) {
      newConfig.drinksMachines = { 
        id: 'drinksMachines', 
        name: 'Drinks Machines', 
        type: 'complex', 
        count: 0, 
        positions: [] 
      };
    }
    newConfig.drinksMachines.count += 1;
    onUpdateConfig(newConfig);
  };
  
  const removeMachine = (machineIndex: number) => {
    const newConfig = { ...configData };
    
    // Remove the machine count
    if (newConfig.drinksMachines) {
      newConfig.drinksMachines.count = Math.max(0, newConfig.drinksMachines.count - 1);
    }
    
    // Remove all machine components for this index
    Object.keys(newConfig).forEach(key => {
      if (key.startsWith(`drinks_machine_${machineIndex}_`)) {
        delete newConfig[key];
      }
    });
    
    // If no machines left, remove the drinksMachines entry
    if (newConfig.drinksMachines && newConfig.drinksMachines.count === 0) {
      delete newConfig.drinksMachines;
    }
    
    onUpdateConfig(newConfig);
    
    // Reset selected machine if it was the one being removed
    if (selectedMachine >= newConfig.drinksMachines?.count || 0) {
      setSelectedMachine(Math.max(0, (newConfig.drinksMachines?.count || 0) - 1));
    }
  };
  
  const addMachineComponent = (componentType: string, machineIndex: number) => {
    const newConfig = { ...configData };
    if (!newConfig.drinksMachines) {
      newConfig.drinksMachines = { 
        id: 'drinksMachines', 
        name: 'Drinks Machines', 
        type: 'complex', 
        count: 0, 
        positions: [] 
      };
    }
    
    // Add component position
    const componentId = `drinks_machine_${componentType}_${machineIndex}`;
    if (!newConfig[componentId]) {
      newConfig[componentId] = { 
        id: componentId, 
        name: `${componentType} for Machine ${machineIndex + 1}`, 
        type: 'vector3', 
        count: 0, 
        positions: [] 
      };
    }
    newConfig[componentId].count += 1;
    onUpdateConfig(newConfig);
  };
  
  const saveMachineType = (machineIndex: number, machineType: string) => {
    const newConfig = { ...configData };
    const typeKey = `drinks_machine_${machineIndex}_type`;
    
    if (!newConfig[typeKey]) {
      newConfig[typeKey] = {
        id: typeKey,
        name: `Machine Type for Machine ${machineIndex + 1}`,
        type: 'vector3',
        count: 0,
        positions: []
      };
    }
    
    // Store the machine type in the first position's type field
    newConfig[typeKey].positions = [{ x: 0, y: 0, z: 0, type: machineType }];
    newConfig[typeKey].count = 1;
    
    onUpdateConfig(newConfig);
  };
  
  const startPositioning = (itemId: string, index: number) => {
    // Ensure the item exists in configData before positioning
    if (!configData[itemId]) {
      const newConfig = { ...configData };
      newConfig[itemId] = {
        id: itemId,
        name: itemId.replace(/_/g, ' '),
        type: 'vector3',
        count: 0,
        positions: []
      };
      onUpdateConfig(newConfig);
    }
    onStartPositioning(itemId, index);
  };

  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-xl font-semibold text-white">Drinks Machine Configuration</h3>
        <button
          onClick={addMachine}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg flex items-center gap-2 transition-colors"
        >
          <Plus size={16} />
          Add Machine
        </button>
      </div>
      
      <div className="flex gap-6 h-full">
        {/* Machine List */}
        <div className="w-1/3 bg-gray-800 rounded-lg p-4 border border-gray-700">
          <h4 className="text-lg font-medium text-white mb-4">Drinks Machines</h4>
          <div className="space-y-2">
            {Array.from({ length: configData.drinksMachines?.count || 0 }, (_, i) => (
              <div key={i} className="flex gap-2">
                <button
                  onClick={() => setSelectedMachine(i)}
                  className={`flex-1 p-3 rounded-lg border transition-all ${
                    selectedMachine === i
                      ? 'bg-blue-600 border-blue-500 text-white'
                      : 'bg-gray-700 border-gray-600 text-gray-300 hover:bg-gray-600'
                  }`}
                >
                  Machine #{i + 1}
                </button>
                <button
                  onClick={() => removeMachine(i)}
                  className="px-3 py-3 bg-red-600 hover:bg-red-700 text-white rounded-lg transition-colors"
                  title="Remove machine"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            ))}
          </div>
          {/* Debug info */}
          <div className="mt-4 p-2 bg-gray-700 rounded text-xs text-gray-400">
            <div>Machines count: {configData.drinksMachines?.count || 0}</div>
            <div>Total config items: {Object.keys(configData).length}</div>
            <div>Machine items: {Object.keys(configData).filter(k => k.startsWith('drinks_machine_')).length}</div>
          </div>
        </div>
        
        {/* Machine Configuration */}
        <div className="flex-1 bg-gray-800 rounded-lg p-4 border border-gray-700">
          {selectedMachine < (configData.drinksMachines?.count || 0) ? (
            <div>
              <h4 className="text-lg font-medium text-white mb-4">
                Machine #{selectedMachine + 1} Configuration
              </h4>
              
              <div className="space-y-6">
                {/* Machine Type Selection */}
                <div>
                  <h5 className="text-md font-medium text-gray-300 mb-3">Machine Type</h5>
                  <div className="grid grid-cols-2 gap-3">
                    {machineTypes.map(type => (
                      <button
                        key={type.id}
                        onClick={() => {
                          setSelectedMachineType(type.id);
                          saveMachineType(selectedMachine, type.id);
                        }}
                        className={`p-3 rounded-lg border transition-all flex items-center gap-2 ${
                          selectedMachineType === type.id
                            ? 'bg-blue-600 border-blue-500 text-white'
                            : 'bg-gray-700 border-gray-600 text-gray-300 hover:bg-gray-600'
                        }`}
                      >
                        {type.icon}
                        <div className="text-sm font-medium">{type.name}</div>
                      </button>
                    ))}
                  </div>
                </div>
                
                {/* Basic Machine Components */}
                <div>
                  <h5 className="text-md font-medium text-gray-300 mb-3">Basic Components</h5>
                  <div className="grid grid-cols-2 gap-3">
                    <button
                      onClick={() => startPositioning(`drinks_machine_${selectedMachine}_coords`, 0)}
                      className="p-3 bg-gray-700 hover:bg-gray-600 rounded-lg border border-gray-600 text-gray-300 transition-colors"
                    >
                      <div className="text-sm font-medium">Machine Coords</div>
                      <div className="text-xs text-gray-400">Machine position</div>
                      {configData[`drinks_machine_${selectedMachine}_coords`]?.positions?.length > 0 && (
                        <div className="text-xs text-green-400 mt-1">✓ Positioned</div>
                      )}
                    </button>
                  </div>
                </div>
                
                {/* Machine Configuration Summary */}
                <div className="bg-gray-700 rounded-lg p-4 border border-gray-600">
                  <h5 className="text-md font-medium text-gray-300 mb-3">Configuration Summary</h5>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-400">Machine Type:</span>
                      <span className="text-white">{machineTypes.find(t => t.id === selectedMachineType)?.name}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-400">Machine Position:</span>
                      <span className={configData[`drinks_machine_${selectedMachine}_coords`]?.positions?.length > 0 ? 'text-green-400' : 'text-red-400'}>
                        {configData[`drinks_machine_${selectedMachine}_coords`]?.positions?.length > 0 ? 'Configured' : 'Not Set'}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="text-center py-12 text-gray-400">
              <Coffee size={48} className="mx-auto mb-4 text-gray-600" />
              <p>No drinks machines configured yet.</p>
              <p className="text-sm">Click "Add Machine" to get started.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default PositionConfigurator; 