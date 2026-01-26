/* ========================================
   PD Boss Menu - Animation Utilities
   Provides interactive effects and animations
   ======================================== */

console.log('=== ANIMATIONS MODULE LOADING ===');

// Animation utilities namespace
const Animations = {
    // ========================================
    // Toast Notification System
    // ========================================
    toastContainer: null,

    initToasts() {
        if (!this.toastContainer) {
            this.toastContainer = document.createElement('div');
            this.toastContainer.className = 'toast-container';
            document.body.appendChild(this.toastContainer);
        }
    },

    showToast(options = {}) {
        this.initToasts();

        const {
            title = 'Notification',
            message = '',
            type = 'info', // info, success, error, warning
            duration = 4000,
            icon = null
        } = options;

        const icons = {
            info: '💡',
            success: '✅',
            error: '❌',
            warning: '⚠️'
        };

        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.innerHTML = `
            <span class="toast-icon">${icon || icons[type]}</span>
            <div class="toast-content">
                <div class="toast-title">${title}</div>
                ${message ? `<div class="toast-message">${message}</div>` : ''}
            </div>
            <button class="toast-close">&times;</button>
        `;

        // Close button handler
        toast.querySelector('.toast-close').addEventListener('click', () => {
            this.dismissToast(toast);
        });

        this.toastContainer.appendChild(toast);

        // Auto dismiss
        if (duration > 0) {
            setTimeout(() => this.dismissToast(toast), duration);
        }

        return toast;
    },

    dismissToast(toast) {
        if (!toast || toast.classList.contains('toast-exit')) return;

        toast.classList.add('toast-exit');
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 300);
    },

    // ========================================
    // Confetti Effect
    // ========================================
    createConfetti(options = {}) {
        const {
            count = 50,
            duration = 3000,
            colors = ['#5078F2', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899']
        } = options;

        const container = document.createElement('div');
        container.className = 'confetti-container';
        document.body.appendChild(container);

        const shapes = ['square', 'circle', 'triangle'];

        for (let i = 0; i < count; i++) {
            const confetti = document.createElement('div');
            const shape = shapes[Math.floor(Math.random() * shapes.length)];
            const color = colors[Math.floor(Math.random() * colors.length)];

            confetti.className = `confetti ${shape}`;
            confetti.style.left = `${Math.random() * 100}%`;
            confetti.style.backgroundColor = shape !== 'triangle' ? color : 'transparent';
            confetti.style.borderBottomColor = color;
            confetti.style.animationDuration = `${2 + Math.random() * 2}s`;
            confetti.style.animationDelay = `${Math.random() * 0.5}s`;

            container.appendChild(confetti);
        }

        // Clean up after animation
        setTimeout(() => {
            if (container.parentNode) {
                container.parentNode.removeChild(container);
            }
        }, duration + 1000);
    },

    // ========================================
    // Ripple Effect
    // ========================================
    createRipple(event) {
        const button = event.currentTarget;

        // Remove existing ripples
        const existingRipple = button.querySelector('.ripple');
        if (existingRipple) {
            existingRipple.remove();
        }

        const ripple = document.createElement('span');
        ripple.className = 'ripple';

        const rect = button.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);

        ripple.style.width = ripple.style.height = `${size}px`;
        ripple.style.left = `${event.clientX - rect.left - size / 2}px`;
        ripple.style.top = `${event.clientY - rect.top - size / 2}px`;

        button.appendChild(ripple);

        // Clean up after animation
        setTimeout(() => {
            if (ripple.parentNode) {
                ripple.remove();
            }
        }, 600);
    },

    initRippleEffects() {
        document.querySelectorAll('.ripple-effect, .btn, button').forEach(button => {
            if (!button.dataset.rippleInit) {
                button.addEventListener('click', this.createRipple.bind(this));
                button.classList.add('ripple-effect');
                button.dataset.rippleInit = 'true';
            }
        });
    },

    // ========================================
    // Number Counter Animation
    // ========================================
    animateCounter(element, start, end, duration = 1000, prefix = '', suffix = '') {
        if (!element) return;

        // Ensure start and end are valid numbers
        start = parseFloat(start) || 0;
        end = parseFloat(end) || 0;

        const startTime = performance.now();
        const isDecimal = String(end).includes('.') || end % 1 !== 0;

        element.classList.add('counting');

        const animate = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);

            // Easing function (ease-out)
            const easeOut = 1 - Math.pow(1 - progress, 3);
            const current = start + (end - start) * easeOut;

            if (isDecimal) {
                element.textContent = `${prefix}${current.toFixed(2)}${suffix}`;
            } else {
                element.textContent = `${prefix}${Math.floor(current).toLocaleString()}${suffix}`;
            }

            if (progress < 1) {
                requestAnimationFrame(animate);
            } else {
                element.classList.remove('counting');
                if (isDecimal) {
                    element.textContent = `${prefix}${end.toFixed(2)}${suffix}`;
                } else {
                    element.textContent = `${prefix}${end.toLocaleString()}${suffix}`;
                }
            }
        };

        requestAnimationFrame(animate);
    },

    // ========================================
    // Staggered Entrance Animation
    // ========================================
    animateStaggered(selector, animationClass = 'animate-fade-in-up', baseDelay = 50) {
        const elements = document.querySelectorAll(selector);

        elements.forEach((el, index) => {
            el.style.opacity = '0';
            el.style.animationDelay = `${index * baseDelay}ms`;

            // Trigger animation on next frame
            requestAnimationFrame(() => {
                el.classList.add(animationClass);
                el.style.opacity = '';
            });
        });
    },

    // ========================================
    // Loading Overlay
    // ========================================
    showLoading(container, message = 'Loading...') {
        if (!container) return null;

        // Remove existing overlay
        this.hideLoading(container);

        const overlay = document.createElement('div');
        overlay.className = 'loading-overlay';
        overlay.innerHTML = `
            <div style="text-align: center;">
                <div class="spinner spinner-lg"></div>
                <div style="margin-top: 12px; font-size: 14px; color: rgba(255,255,255,0.8);">${message}</div>
            </div>
        `;

        container.style.position = 'relative';
        container.appendChild(overlay);

        return overlay;
    },

    hideLoading(container) {
        if (!container) return;

        const overlay = container.querySelector('.loading-overlay');
        if (overlay) {
            overlay.style.opacity = '0';
            setTimeout(() => {
                if (overlay.parentNode) {
                    overlay.remove();
                }
            }, 200);
        }
    },

    // ========================================
    // Skeleton Loading
    // ========================================
    createSkeleton(type = 'card') {
        const skeleton = document.createElement('div');

        switch (type) {
            case 'card':
                skeleton.className = 'skeleton skeleton-card';
                break;
            case 'avatar':
                skeleton.className = 'skeleton skeleton-avatar';
                break;
            case 'text':
                skeleton.className = 'skeleton skeleton-text';
                break;
            case 'text-short':
                skeleton.className = 'skeleton skeleton-text short';
                break;
            case 'row':
                skeleton.innerHTML = `
                    <div style="display: flex; align-items: center; gap: 12px; padding: 12px;">
                        <div class="skeleton skeleton-avatar"></div>
                        <div style="flex: 1;">
                            <div class="skeleton skeleton-text medium"></div>
                            <div class="skeleton skeleton-text short"></div>
                        </div>
                    </div>
                `;
                break;
            default:
                skeleton.className = 'skeleton';
        }

        return skeleton;
    },

    showSkeletonList(container, count = 5) {
        if (!container) return;

        container.innerHTML = '';

        for (let i = 0; i < count; i++) {
            container.appendChild(this.createSkeleton('row'));
        }
    },

    // ========================================
    // Tab Transition
    // ========================================
    switchTab(oldTab, newTab) {
        if (!oldTab || !newTab) return;

        // Exit animation for old tab
        if (oldTab.classList.contains('active')) {
            oldTab.classList.add('tab-exit');

            setTimeout(() => {
                oldTab.classList.remove('active', 'tab-exit');

                // Enter animation for new tab
                newTab.classList.add('active');
            }, 200);
        } else {
            newTab.classList.add('active');
        }
    },

    // ========================================
    // Button Glow Effect
    // ========================================
    initButtonEffects() {
        document.querySelectorAll('.btn, button').forEach(btn => {
            if (!btn.classList.contains('btn-glow') && !btn.classList.contains('close-btn') && !btn.classList.contains('toast-close')) {
                btn.classList.add('btn-glow');
            }
        });
    },

    // ========================================
    // Shake Animation (for errors)
    // ========================================
    shake(element) {
        if (!element) return;

        element.style.animation = 'none';
        element.offsetHeight; // Trigger reflow
        element.style.animation = 'shake 0.5s ease';

        setTimeout(() => {
            element.style.animation = '';
        }, 500);
    },

    // ========================================
    // Success Celebration
    // ========================================
    celebrate(options = {}) {
        const {
            title = 'Success!',
            message = '',
            confetti = true
        } = options;

        // Show toast
        this.showToast({
            title,
            message,
            type: 'success',
            duration: 5000
        });

        // Trigger confetti
        if (confetti) {
            this.createConfetti();
        }
    },

    // ========================================
    // Initialize All Effects
    // ========================================
    init() {
        console.log('Initializing animations...');

        // Initialize toast container
        this.initToasts();

        // Initialize ripple effects
        this.initRippleEffects();

        // Initialize button effects
        this.initButtonEffects();

        // Re-initialize on DOM changes
        const observer = new MutationObserver((mutations) => {
            let shouldReinit = false;

            mutations.forEach(mutation => {
                if (mutation.addedNodes.length > 0) {
                    shouldReinit = true;
                }
            });

            if (shouldReinit) {
                this.initRippleEffects();
                this.initButtonEffects();
            }
        });

        observer.observe(document.body, {
            childList: true,
            subtree: true
        });

        console.log('Animations initialized!');
    }
};

// Add shake keyframes dynamically
const shakeStyle = document.createElement('style');
shakeStyle.textContent = `
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
        20%, 40%, 60%, 80% { transform: translateX(5px); }
    }
`;
document.head.appendChild(shakeStyle);

// Expose globally
window.Animations = Animations;

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => Animations.init());
} else {
    Animations.init();
}

console.log('=== ANIMATIONS MODULE LOADED ===');
