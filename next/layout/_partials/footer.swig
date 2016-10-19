<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}
  &copy; {% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
  <span itemprop="copyrightYear">{{ current }}</span>
  <span class="with-love">
    <i class="icon-next-heart fa fa-heart"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ config.author }}</span>
</div>

<div>
	<span id="busuanzi_container_site_pv">
	    本站总访问量<span id="busuanzi_value_site_pv"></span>次
	    您是第<span id="busuanzi_value_site_uv"></span>个小伙伴
	</span>
</div>


<script async src="https://dn-lbstatics.qbox.me/busuanzi/2.3/busuanzi.pure.mini.js">
</script>

{% block footer %}{% endblock %}
