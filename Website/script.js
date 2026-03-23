// Initialize Lucide icons
lucide.createIcons();

document.addEventListener('DOMContentLoaded', () => {
    const downloadBtn = document.getElementById('downloadBtn');
    const modal = document.getElementById('downloadModal');
    const progressFill = document.querySelector('.progress-fill');
    
    downloadBtn.addEventListener('click', (e) => {
        e.preventDefault();
        
        // Show modal
        modal.classList.add('active');
        
        // Disable scroll
        document.body.style.overflow = 'hidden';
        
        // Simulate download progress
        let progress = 0;
        const interval = setInterval(() => {
            progress += Math.random() * 15 + 5; // Random chunk
            if (progress >= 100) {
                progress = 100;
                clearInterval(interval);
                
                progressFill.style.width = '100%';
                
                // Once "download" reaches 100, we wait a moment, create a dummy file and trigger download
                setTimeout(() => {
                    triggerDummyDownload();
                    
                    // Close modal and reset
                    modal.classList.remove('active');
                    document.body.style.overflow = 'auto';
                    setTimeout(() => {
                        progressFill.style.width = '0%';
                    }, 300);
                }, 800);
                
            } else {
                progressFill.style.width = `${progress}%`;
            }
        }, 300);
    });
    
    // Close modal if clicked outside content
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.classList.remove('active');
            document.body.style.overflow = 'auto';
            setTimeout(() => {
                progressFill.style.width = '0%';
            }, 300);
        }
    });
});

function triggerDummyDownload() {
    // We create a dummy file Blob to actually demonstrate the download behavior
    // Since the actual APK isn't here, we download a txt file that pretends to be the app
    const content = "This is a placeholder for the One Snap Mista To Decode The Truths APK file.";
    const blob = new Blob([content], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = "OneSnapMista_v1.0.apk"; // Filename to save
    document.body.appendChild(a);
    a.click();
    
    // Cleanup
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}
