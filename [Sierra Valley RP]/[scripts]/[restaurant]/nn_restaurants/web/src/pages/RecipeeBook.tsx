import React, { useState, useEffect } from 'react';
import '../recipe-book.css';
import { useVisibility } from '../providers/VisibilityProvider';
import { fetchNui } from '../utils/fetchNui';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { t } from '../utils/translations';

interface Recipe {
  id: number;
  name: string;
  description?: string;
  category: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  cookingTime: string;
  servings: number;
  ingredients: string[];
  instructions: string[];
  notes?: string[];
  tips?: string[];
}

const RecipeBook: React.FC = () => {
  const {visibility} = useVisibility()
  const [currentPage, setCurrentPage] = useState(0);
  const [isFlipping, setIsFlipping] = useState(false);
  const [flipDirection, setFlipDirection] = useState<'next' | 'prev'>('next');

  // State for recipes data
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [loading, setLoading] = useState(true);

  // State for restaurant ID
  const [restaurantId, setRestaurantId] = useState<number | null>(null);

  // State for inventory checking
  const [inventoryStatus, setInventoryStatus] = useState<{[key: string]: boolean}>({});
  const [checkingInventory, setCheckingInventory] = useState(false);

  // Listen for recipe book open event
  useEffect(() => {
    const handleOpenRecipeBook = (event: CustomEvent) => {
      setRestaurantId(event.detail.restaurantId);
    };

    window.addEventListener('openRecipeBook', handleOpenRecipeBook as EventListener);
    
    return () => {
      window.removeEventListener('openRecipeBook', handleOpenRecipeBook as EventListener);
    };
  }, []);

  useNuiEvent('setRecipeBookData', (data: Recipe[]) => {
    setRecipes(data);
  });

  // Check inventory for current recipe ingredients
  const checkInventoryForRecipe = async (recipe: Recipe) => {
    if (!recipe.ingredients || recipe.ingredients.length === 0) return;
    
    setCheckingInventory(true);
    try {
      const hasIngredients = await fetchNui('checkInventory', {
        ingredients: recipe.ingredients
      }) as {[key: string]: boolean};
      setInventoryStatus(hasIngredients);
    } catch (error) {
      console.error('Failed to check inventory:', error);
    } finally {
      setCheckingInventory(false);
    }
  };

  // Start cooking the current recipe
  const startCooking = async (recipe: Recipe) => {
    try {
      await fetchNui('startCooking', {
        recipeId: recipe.id
      });
      // Close the recipe book after starting cooking
      fetchNui('hideFrame', {});
    } catch (error) {
      console.error('Failed to start cooking:', error);
    }
  };

  // Check if player has all ingredients for a recipe
  const hasAllIngredients = (recipe: Recipe) => {
    if (!recipe.ingredients || recipe.ingredients.length === 0) return false;
    return recipe.ingredients.every(ingredient => inventoryStatus[ingredient]);
  };

  // Check inventory when recipe page is displayed
  useEffect(() => {
    if (currentPageData && currentPageData.type === 'recipe' && currentPageData.recipe) {
      checkInventoryForRecipe(currentPageData.recipe);
    }
  }, [currentPage, recipes]);

  const pages = [
    { type: 'contents' as const },
    ...recipes.map(recipe => ({ type: 'recipe' as const, recipe }))
  ];

  const totalPages = pages.length;

  const nextPage = () => {
    if (currentPage < totalPages - 1 && !isFlipping) {
      setIsFlipping(true);
      setFlipDirection('next');
      
      setTimeout(() => {
        setCurrentPage(currentPage + 1);
        setIsFlipping(false);
      }, 100); // Simple fade transition
    }
  };

  const prevPage = () => {
    if (currentPage > 0 && !isFlipping) {
      setIsFlipping(true);
      setFlipDirection('prev');
      
      setTimeout(() => {
        setCurrentPage(currentPage - 1);
        setIsFlipping(false);
      }, 100); // Simple fade transition
    }
  };

  const goToPage = (pageIndex: number) => {
    if (pageIndex !== currentPage && !isFlipping) {
      setIsFlipping(true);
      setFlipDirection(pageIndex > currentPage ? 'next' : 'prev');
      
      setTimeout(() => {
        setCurrentPage(pageIndex);
        setIsFlipping(false);
      }, 100);
    }
  };

  const currentPageData = pages[currentPage];
  const nextPageData = currentPage < totalPages - 1 ? pages[currentPage + 1] : null;

  const renderPageContent = (pageData: typeof pages[0]) => {
    if (pageData.type === 'contents') {
      return (
        <div className="contents-page">
          <div className="page-header">
            <h1 className="book-title">{t('my_recipe_collection')}</h1>
            <div className="decorative-line"></div>
          </div>
          
          <div className="table-of-contents">
            <h2 className="contents-title">{t('table_of_contents')}</h2>
            
            {recipes.map((recipe, index) => (
              <div 
                key={recipe.id} 
                className="contents-item"
                onClick={() => goToPage(index + 1)}
              >
                <span className="recipe-name">{recipe.name}</span>
                <span className="page-dots">...</span>
                <span className="page-number">{index + 1}</span>
              </div>
            ))}
          </div>
          
          <div className="page-footer">
            <div className="footer-note">
              {t('family_recipes_note')}
            </div>
          </div>
        </div>
      );
    } else {
      const recipe = pageData.recipe;
      return (
        <div className="recipe-page">
          <div className="recipe-header">
            <h1 className="recipe-title">{recipe.name}</h1>
          </div>

          <div className="recipe-content">
            <div className="recipe-left">
              <div className="ingredients-section">
                <h2 className="section-title">{t('ingredients')}</h2>
                <ul className="ingredients-list">
                  {recipe.ingredients.map((ingredient, index) => (
                    <li key={index} className={`ingredient-item ${inventoryStatus[ingredient] ? 'has-ingredient' : ''}`}>
                      <span className="amount">1</span>
                      <span className="ingredient-name">{ingredient}</span>
                      {checkingInventory ? (
                        <span className="inventory-check">{t('inventory_check')}</span>
                      ) : (
                        <span className={`inventory-status ${inventoryStatus[ingredient] ? 'has-item' : 'missing-item'}`}>
                          {inventoryStatus[ingredient] ? '✓' : '✗'}
                        </span>
                      )}
                    </li>
                  ))}
                </ul>
              </div>

              {recipe.notes && recipe.notes.length > 0 && (
                <div className="notes-section">
                  <h3 className="notes-title">{t('chefs_note')}</h3>
                  {recipe.notes.map((note, index) => (
                    <p key={index} className="notes-text">{note}</p>
                  ))}
                </div>
              )}
            </div>

            <div className="recipe-right">
              <div className="instructions-section">
                <h2 className="section-title">{t('instructions')}</h2>
                <ol className="instructions-list">
                  {recipe.instructions.map((instruction, index) => (
                    <li key={index} className="instruction-item">
                      {instruction}
                    </li>
                  ))}
                </ol>
              </div>

              {recipe.tips && recipe.tips.length > 0 && (
                <div className="tips-section">
                  <h3 className="tips-title">{t('pro_tips')}</h3>
                  <ul className="tips-list">
                    {recipe.tips.map((tip, index) => (
                      <li key={index} className="tip-item">
                        💡 {tip}
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          </div>

          {/* Cooking Button */}
          {hasAllIngredients(recipe) && (
            <div className="cooking-section">
              <button 
                className="cooking-button"
                onClick={() => startCooking(recipe)}
                disabled={checkingInventory}
              >
                <span className="cooking-button-text">{t('start_cooking')}</span>
              </button>
            </div>
          )}

          <div className="page-navigation">
            <button 
              className="page-nav-btn prev-btn"
              onClick={prevPage}
              disabled={currentPage === 0 || isFlipping}
              title={t('previous_page')}
            >
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M15 18L9 12L15 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </button>
            
            <span className="page-number">
              {currentPage + 1}
            </span>
            
            <button 
              className="page-nav-btn next-btn"
              onClick={nextPage}
              disabled={currentPage >= totalPages - 1 || isFlipping}
              title={t('next_page')}
            >
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M9 18L15 12L9 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </button>
          </div>
        </div>
      );
    }
  };

  if (!visibility.visible || visibility.page !== "recipe-book") return null;

  return (
    <div className="recipe-book">
      {/* Close button */}
      <button 
        className="recipe-book-close-btn"
        onClick={() => {
            fetchNui('hideFrame', {});
        }}
        title={t('close_recipe_book')}
      >
        ✕
      </button>
      
      <div className="book-cover">
        <div className="book-spine"></div>
        
        <div className="single-page-container">
          {/* Bottom layer - next page content (always rendered) */}
          <div className="bottom-page">
            {nextPageData && renderPageContent(nextPageData)}
          </div>
          
          {/* Top layer - current page (flips away) */}
          <div className={`top-page ${isFlipping ? `flipping-${flipDirection}` : ''}`}>
            {renderPageContent(currentPageData)}
          </div>
        </div>
      </div>
    </div>
  );
};

export default RecipeBook;
