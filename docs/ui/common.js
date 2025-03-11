// 通用JavaScript文件，用于添加状态栏和底部导航栏以及交互逻辑

// 全局变量和工具函数
const pages = {
    'home.html': '首页',
    'tasks.html': '任务',
    'history.html': '历史',
    'profile.html': '个人中心',
    'settings.html': '设置',
    'recharge.html': '充值中心'
};

// 格式化时间的函数
function formatTime(date) {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
}

// 在页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 获取当前页面的文件名
    const currentPage = window.location.pathname.split('/').pop();
    
    // 如果当前页面是index.html，不执行任何操作
    if (currentPage === 'index.html') return;
    
    // 获取body元素
    const body = document.body;
    const originalContent = body.innerHTML;
    
    // 清空body内容
    body.innerHTML = '';
    
    // 创建设备框架
    const deviceFrame = document.createElement('div');
    deviceFrame.className = 'device-frame';
    
    // 添加状态栏
    const statusBar = document.createElement('div');
    statusBar.className = 'status-bar';
    
    // 获取当前时间
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    const currentTime = `${hours}:${minutes}`;
    
    statusBar.innerHTML = `
        <div class="notch"></div>
        <div class="time">${currentTime}</div>
        <div class="status-icons">
            <i class="fas fa-signal"></i>
            <i class="fas fa-wifi"></i>
            <i class="fas fa-battery-full"></i>
        </div>
    `;
    
    // 创建内容容器
    const contentContainer = document.createElement('div');
    contentContainer.className = 'page-content';
    contentContainer.innerHTML = originalContent;
    
    // 创建底部标签栏
    const tabBar = document.createElement('div');
    tabBar.className = 'tab-bar';
    
    // 定义导航项
    const navItems = [
        { href: 'home.html', icon: 'fa-home', text: '首页' },
        { href: 'tasks.html', icon: 'fa-tasks', text: '任务' },
        { href: 'history.html', icon: 'fa-history', text: '历史' },
        { href: 'profile.html', icon: 'fa-user', text: '我的' }
    ];
    
    // 添加页面交互逻辑
    addPageInteractions();
    
    // 生成导航HTML
    const navHTML = navItems.map(item => {
        const isActive = currentPage === item.href;
        const bgColor = isActive ? 'bg-gradient-to-r from-blue-500 to-purple-500' : 'bg-gray-50';
        const textColor = isActive ? 'text-white' : 'text-gray-500';
        const fontWeight = isActive ? 'font-medium' : 'font-normal';
        const labelColor = isActive ? 'text-blue-600' : 'text-gray-500';
        
        return `
            <a href="${item.href}" class="flex flex-col items-center space-y-1 tab-icon">
                <div class="w-10 h-10 rounded-full ${bgColor} flex items-center justify-center shadow-sm transition-all duration-300">
                    <i class="fas ${item.icon} ${textColor} text-sm"></i>
                </div>
                <span class="text-xs ${labelColor} ${fontWeight} transition-all duration-300">${item.text}</span>
            </a>
        `;
    }).join('');
    
    tabBar.innerHTML = navHTML;
    
    // 将元素添加到设备框架中
    deviceFrame.appendChild(statusBar);
    deviceFrame.appendChild(contentContainer);
    deviceFrame.appendChild(tabBar);
    
    // 将设备框架添加到body中
    body.appendChild(deviceFrame);
    
    // 添加必要的CSS样式
    const style = document.createElement('style');
    
    // 添加页面交互逻辑函数
    function addPageInteractions() {
        // 处理返回按钮
        const backButtons = document.querySelectorAll('.fa-arrow-left').forEach(btn => {
            const parentBtn = btn.closest('button');
            if (parentBtn) {
                parentBtn.addEventListener('click', function() {
                    window.history.back();
                });
            }
        });
        
        // 处理设置按钮
        const settingsButtons = document.querySelectorAll('.fa-cog').forEach(btn => {
            const parentBtn = btn.closest('button');
            if (parentBtn) {
                parentBtn.addEventListener('click', function() {
                    window.location.href = 'settings.html';
                });
            }
        });
        
        // 处理充值入口 - 修改这里，直接使用事件委托方式绑定到document上
        document.addEventListener('click', function(e) {
            // 查找点击元素或其父元素是否有data-action="recharge"属性
            let target = e.target;
            while (target && target !== document) {
                if (target.getAttribute('data-action') === 'recharge') {
                    console.log('充值按钮被点击，跳转到充值页面');
                    window.location.href = 'recharge.html';
                    return;
                }
                target = target.parentNode;
            }
        });
        
        // 处理历史记录项的播放和删除按钮
        const historyPlayButtons = document.querySelectorAll('.history-item .fa-play').forEach(btn => {
            const parentBtn = btn.closest('button');
            if (parentBtn) {
                parentBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    const historyItem = parentBtn.closest('.history-item');
                    if (historyItem) {
                        const itemId = historyItem.dataset.id;
                        console.log('播放历史记录项:', itemId);
                        // 这里可以添加播放视频的逻辑
                    }
                });
            }
        });
        
        const historyDeleteButtons = document.querySelectorAll('.history-item .fa-trash').forEach(btn => {
            const parentBtn = btn.closest('button');
            if (parentBtn) {
                parentBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    const historyItem = parentBtn.closest('.history-item');
                    if (historyItem) {
                        const itemId = historyItem.dataset.id;
                        console.log('删除历史记录项:', itemId);
                        historyItem.classList.add('scale-95', 'opacity-0');
                        setTimeout(() => {
                            historyItem.remove();
                        }, 300);
                    }
                });
            }
        });
        
        // 处理设置页面的开关和选项
        const toggleSwitches = document.querySelectorAll('.toggle-switch').forEach(toggle => {
            toggle.addEventListener('click', function() {
                const switchBall = this.querySelector('.switch-ball');
                const isActive = switchBall.classList.contains('switch-active');
                
                if (isActive) {
                    switchBall.classList.remove('switch-active');
                    switchBall.style.transform = 'translateX(0)';
                    this.classList.remove('bg-indigo-500');
                    this.classList.add('bg-gray-200');
                } else {
                    switchBall.classList.add('switch-active');
                    switchBall.style.transform = 'translateX(24px)';
                    this.classList.remove('bg-gray-200');
                    this.classList.add('bg-indigo-500');
                }
            });
        });
        
        // 处理充值页面的套餐选择
        const packageItems = document.querySelectorAll('.package-item').forEach(item => {
            item.addEventListener('click', function() {
                // 移除其他套餐的选中状态
                document.querySelectorAll('.package-item').forEach(pkg => {
                    pkg.classList.remove('border-indigo-500');
                    pkg.classList.add('border-gray-200');
                });
                
                // 添加当前套餐的选中状态
                this.classList.remove('border-gray-200');
                this.classList.add('border-indigo-500');
            });
        });
    }
    style.textContent = `
        :root {
            --primary-color: #4F46E5;
            --secondary-color: #8B5CF6;
            --accent-color: #EC4899;
            --gradient-primary: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            --gradient-accent: linear-gradient(135deg, var(--secondary-color), var(--accent-color));
            --shadow-sm: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-md: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --shadow-lg: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }
        body {
            background-color: #f8fafc;
            background-image: radial-gradient(at 30% 20%, rgba(79, 70, 229, 0.05) 0px, transparent 50%),
                             radial-gradient(at 80% 70%, rgba(236, 72, 153, 0.05) 0px, transparent 50%);
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        .device-frame {
            width: 390px;
            height: 844px;
            border-radius: 54px;
            background: white;
            position: relative;
            overflow: hidden;
            box-shadow: 0 0 0 11px #1a1a1a, 0 0 0 13px #000, 0 20px 50px rgba(0, 0, 0, 0.2);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        .device-frame:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 0 0 11px #1a1a1a, 0 0 0 13px #000, 0 30px 60px rgba(0, 0, 0, 0.3);
        }
        .status-bar {
            height: 47px;
            background: #fff;
            position: relative;
            display: flex;
            align-items: center;
            padding: 0 20px;
            color: #333;
            font-size: 14px;
            z-index: 10;
        }
        .notch {
            width: 126px;
            height: 32px;
            background: #fff;
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            border-bottom-left-radius: 24px;
            border-bottom-right-radius: 24px;
            z-index: 1;
        }
        .time {
            position: absolute;
            left: 32px;
            font-weight: 600;
        }
        .status-icons {
            position: absolute;
            right: 32px;
            display: flex;
            gap: 6px;
        }
        .tab-bar {
            position: absolute;
            bottom: 0;
            width: 100%;
            height: 84px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-top: 1px solid rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: space-around;
            align-items: center;
            padding-bottom: 20px;
            box-shadow: 0 -1px 10px rgba(0, 0, 0, 0.05);
            z-index: 10;
        }
        .page-content {
            height: 713px; /* 844 - 47 - 84 */
            overflow-y: auto;
            padding-bottom: 20px;
            background-color: #ffffff;
            transition: opacity 0.3s ease;
        }
        .tab-icon {
            transition: all 0.3s ease;
        }
        .tab-icon:hover {
            transform: translateY(-3px);
        }
        /* 美化滚动条 */
        .page-content::-webkit-scrollbar {
            width: 6px;
        }
        .page-content::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.02);
        }
        .page-content::-webkit-scrollbar-thumb {
            background: rgba(0, 0, 0, 0.1);
            border-radius: 3px;
        }
        .page-content::-webkit-scrollbar-thumb:hover {
            background: rgba(0, 0, 0, 0.2);
        }
        /* 通用元素美化 */
        button {
            transition: all 0.3s ease;
        }
        button:active {
            transform: scale(0.95);
        }
        input {
            transition: all 0.3s ease;
        }
        .gradient-text {
            background: var(--gradient-primary);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .gradient-bg {
            background: var(--gradient-primary);
        }
        .card {
            transition: all 0.3s ease;
            border-radius: 16px;
            overflow: hidden;
        }
        .card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-md);
        }
    `;
    
    // 将样式添加到head中
    document.head.appendChild(style);
    
    // 添加页面过渡动画
    contentContainer.style.opacity = '0';
    setTimeout(() => {
        contentContainer.style.opacity = '1';
    }, 100);
    
    // 为所有按钮添加涟漪效果
    const addRippleEffect = (element) => {
        element.addEventListener('click', function(e) {
            const ripple = document.createElement('span');
            ripple.classList.add('ripple');
            this.appendChild(ripple);
            
            const rect = this.getBoundingClientRect();
            const size = Math.max(rect.width, rect.height);
            
            ripple.style.width = ripple.style.height = `${size}px`;
            ripple.style.left = `${e.clientX - rect.left - size / 2}px`;
            ripple.style.top = `${e.clientY - rect.top - size / 2}px`;
            
            ripple.classList.add('active');
            
            setTimeout(() => {
                ripple.remove();
            }, 600);
        });
    };
    
    // 添加涟漪效果样式
    const rippleStyle = document.createElement('style');
    rippleStyle.textContent = `
        .ripple {
            position: absolute;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            transform: scale(0);
            animation: ripple 0.6s linear;
            pointer-events: none;
        }
        
        @keyframes ripple {
            to {
                transform: scale(4);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(rippleStyle);
    
    // 为所有按钮添加涟漪效果
    setTimeout(() => {
        document.querySelectorAll('button').forEach(button => {
            button.style.position = 'relative';
            button.style.overflow = 'hidden';
            addRippleEffect(button);
        });
    }, 500);

    
    // 将样式添加到head中
    document.head.appendChild(style);
});